// api.js con Fetch API (nativo)
const BASE_URL = "https://tu-servidor-api.com/api"; // Cambia por tu dirección

// Ejemplo: obtener todos los registros
// api.js - ResiliOS POS
// Propósito: Cliente HTTP unificado para Edge y Cloud, manejo de conectividad y peticiones
// Stack: Vanilla JS / Fetch API, compatible con React PWA
// Estándares: ULID, manejo de errores, detección de estado de red

// ==================== CONFIGURACIÓN ====================
// URLs según entorno: Edge corre en red local, Cloud es el SaaS
const CONFIG = {
  EDGE_API_URL: process.env.REACT_APP_EDGE_URL || "http://localhost:3000/api/v1",
  CLOUD_API_URL: process.env.REACT_APP_CLOUD_URL || "https://api.resilios.com/api/v1",
  TIMEOUT: 15000, // 15s máximo por petición
  SYNC_BATCH_SIZE: 50 // Cantidad de registros a sincronizar por lote
};

// Estado global de conectividad
let isOnline = navigator.onLine;
let isSyncing = false;

// ==================== DETECCIÓN DE CONEXIÓN ====================
// Actualizar estado cuando cambia la red
window.addEventListener('online', () => {
  isOnline = true;
  triggerSync(); // Al recuperar conexión, disparar sincronización automática
  updateStatusIndicator('online');
});

window.addEventListener('offline', () => {
  isOnline = false;
  updateStatusIndicator('offline');
});

function updateStatusIndicator(status) {
  // Actualiza el indicador visual: verde=online, rojo=offline, amarillo=sincronizando
  window.dispatchEvent(new CustomEvent('connection-status', { detail: status }));
}

// ==================== FUNCIÓN BASE DE PETICIONES ====================
/**
 * Petición genérica a la API
 * @param {string} endpoint - Ruta del recurso
 * @param {string} method - GET, POST, PUT, DELETE
 * @param {object} data - Datos a enviar (opcional)
 * @param {boolean} useCloud - ¿Usar la nube en vez del Edge?
 * @returns {Promise<any>} Datos de respuesta
 */
async function request(endpoint, method = 'GET', data = null, useCloud = false) {
  const baseURL = useCloud ? CONFIG.CLOUD_API_URL : CONFIG.EDGE_API_URL;
  const url = `${baseURL}${endpoint}`;

  const options = {
    method,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-ResiliOS-Client': 'POS-PWA',
      'X-Request-ID': generateULID() // Trazabilidad por ULID
    },
    credentials: 'include', // Para sesión y tokens JWT
    signal: AbortSignal.timeout(CONFIG.TIMEOUT)
  };

  // Agregar cuerpo solo si hay datos
  if (data) {
    // Agregar metadatos obligatorios
    const payload = {
      ...data,
      ulid: data.ulid || generateULID(), // Garantizar ULID
      timestamp: new Date().toISOString(),
      source: useCloud ? 'cloud' : 'edge'
    };
    options.body = JSON.stringify(payload);
  }

  try {
    const response = await fetch(url, options);
    
    // Manejo de códigos de estado
    if (!response.ok) {
      const errorData = await response.json().catch(() => ({ message: 'Error desconocido' }));
      throw {
        status: response.status,
        message: errorData.message || `HTTP ${response.status}`,
        code: errorData.code || 'UNKNOWN_ERROR'
      };
    }

    const result = await response.json();
    return result.data || result;

  } catch (error) {
    // Si es error de red o timeout y estamos intentando conectar a la nube
    if (useCloud && (error.name === 'TimeoutError' || !isOnline)) {
      // Guardar operación para sincronizar después (Patrón Outbox)
      await saveOperationToQueue(endpoint, method, data);
      throw { status: 0, message: 'Sin conexión. Operación guardada para más tarde.', offline: true };
    }
    
    console.error(`[API Error] ${method} ${url}:`, error);
    throw error;
  }
}

// ==================== GENERADOR DE ULID ====================
// Cumple estándar definido en la página 10 de su documento
function generateULID() {
  // Implementación simplificada, reemplazar con librería ulid-js en producción
  return Date.now().toString(36) + Math.random().toString(36).substring(2, 10);
}

// ==================== COLA DE SINCRONIZACIÓN (OUTBOX PATTERN) ====================
// Almacena operaciones en SQLite / IndexedDB cuando no hay internet
async function saveOperationToQueue(endpoint, method, data) {
  const operation = {
    ulid: generateULID(),
    endpoint,
    method,
    payload: data,
    created_at: new Date().toISOString(),
    attempts: 0,
    status: 'pending'
  };

  // Guardar en almacenamiento local (IndexedDB o tabla sync_operations en SQLite)
  const queue = JSON.parse(localStorage.getItem('sync_queue') || '[]');
  queue.push(operation);
  localStorage.setItem('sync_queue', JSON.stringify(queue));
  
  // Actualizar contador visual
  updatePendingCount(queue.length);
}

// Disparador de sincronización automática
async function triggerSync() {
  if (!isOnline || isSyncing) return;

  try {
    isSyncing = true;
    updateStatusIndicator('syncing');
    
    const queue = JSON.parse(localStorage.getItem('sync_queue') || '[]');
    const pending = queue.filter(op => op.status === 'pending');

    if (pending.length === 0) {
      updateStatusIndicator('online');
      return;
    }

    // Procesar por lotes
    for (let i = 0; i < pending.length; i += CONFIG.SYNC_BATCH_SIZE) {
      const batch = pending.slice(i, i + CONFIG.SYNC_BATCH_SIZE);
      await processSyncBatch(batch);
    }

    // Limpiar cola y marcar éxito
    const remaining = queue.filter(op => op.status === 'pending' && op.attempts < 5);
    localStorage.setItem('sync_queue', JSON.stringify(remaining));
    updatePendingCount(remaining.length);

  } catch (syncError) {
    console.error('Error en sincronización:', syncError);
  } finally {
    isSyncing = false;
    updateStatusIndicator(isOnline ? 'online' : 'offline');
  }
}

// Procesar lote de operaciones
async function processSyncBatch(batch) {
  for (const op of batch) {
    try {
      op.attempts += 1;
      // Enviar a la nube
      await request(op.endpoint, op.method, op.payload, true);
      op.status = 'completed';
    } catch (err) {
      // Política de reintentos
      op.status = op.attempts >= 5 ? 'failed' : 'pending';
    }
  }
}

function updatePendingCount(count) {
  window.dispatchEvent(new CustomEvent('pending-sync', { detail: count }));
}

// ==================== MÓDULOS DE RECURSOS ====================
// Aquí organizamos los endpoints según las entidades de su sistema: Order, Product, Table, etc.

export const OrderAPI = {
  // Obtener todos los pedidos (Edge)
  getAll: (filters = {}) => request('/orders', 'GET', filters),
  
  // Crear pedido (si está offline se guarda en cola)
  create: (orderData) => request('/orders', 'POST', orderData),
  
  // Actualizar estado (ej: preparado, pagado)
  updateStatus: (orderId, status) => request(`/orders/${orderId}/status`, 'PUT', { status }),
  
  // Sincronizar manualmente
  syncAll: () => triggerSync()
};

export const ProductAPI = {
  getAll: () => request('/products'),
  getById: (id) => request(`/products/${id}`),
  // Productos se gestionan desde la nube y bajan al Edge
  syncFromCloud: () => request('/products/sync', 'POST', {}, true)
};

export const TableAPI = {
  getAll: () => request('/tables'),
  updateStatus: (tableId, status) => request(`/tables/${tableId}`, 'PUT', { status })
};

export const SyncAPI = {
  now: () => triggerSync(),
  getStatus: () => ({ online: isOnline, syncing: isSyncing }),
  getPendingCount: () => JSON.parse(localStorage.getItem('sync_queue') || '[]').length
};

// Exportación principal
export default {
  OrderAPI,
  ProductAPI,
  TableAPI,
  SyncAPI,
  request
};
