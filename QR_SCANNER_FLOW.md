# 📱 Flujo del Lector de Códigos QR - Caritas

## 🎯 Resumen Ejecutivo

El sistema de escaneo QR permite que los administradores de bazar identifiquen rápidamente las donaciones sin necesidad de búsquedas manuales. Al escanear el código, el sistema automáticamente:
1. Extrae el ID de la donación
2. Busca en Firestore
3. Muestra los detalles
4. Permite confirmar entrega

---

## 📊 Diagrama de Flujo Principal

```
┌─────────────────────────────────────────────────────────────────┐
│                    ADMIN DE BAZAR EN APP                        │
│              (BazarAdminDonationsView)                          │
└─────────────────┬───────────────────────────────────────────────┘
                  │
                  │ Presiona botón de cámara QR
                  │ (showQRScanner = true)
                  ▼
┌─────────────────────────────────────────────────────────────────┐
│                  📸 VISTA DEL ESCÁNER                           │
│              (QRScannerView - UI)                              │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │ [X] Escanear QR                              [⚙️ Settings] │ │
│  │                                                             │ │
│  │          CÁMARA EN VIVO                                    │ │
│  │                                                             │ │
│  │            ┌─────────────┐                                │ │
│  │            │   MARCO QR  │                                │ │
│  │            │             │                                │ │
│  │            └─────────────┘                                │ │
│  │                                                             │ │
│  │      "Acerca el QR a la cámara"                           │ │
│  └───────────────────────────────────────────────────────────┘ │
└─────────────────┬───────────────────────────────────────────────┘
                  │
                  │ Usuario apunta QR
                  │ (CIQRCodeGenerator detecta)
                  ▼
┌─────────────────────────────────────────────────────────────────┐
│            🔍 PROCESAMIENTO DE ESCANEO                          │
│       (QRScannerViewController)                                │
│                                                                 │
│  • AVCaptureMetadataOutput detecta código QR                  │
│  • Extrae stringValue del QR (ID de donación)                │
│  • Vibración haptic (feedback al usuario)                    │
│  • Pausa la sesión de cámara                                 │
│  • Llamar callback: onQRDetected(qrContent)                  │
└─────────────────┬───────────────────────────────────────────────┘
                  │
                  │ QR detectado
                  │ (Ej: "D-12345")
                  ▼
┌─────────────────────────────────────────────────────────────────┐
│          🔎 BÚSQUEDA EN FIRESTORE                              │
│      (QRScannerViewModel.handleQRDetected)                     │
│                                                                 │
│  • isLoading = true                                            │
│  • FirestoreService.fetchDonation(by: qrContent)             │
│  • Query: db.collection("donations").document(id)             │
└─────────────────┬───────────────────────────────────────────────┘
                  │
                  ▼
        ┌─────────────────────┐
        │ ¿Donación existe?   │
        └─────────┬───────────┘
                  │
        ┌─────────┴─────────┐
        │                   │
        ▼ SÍ                ▼ NO
┌──────────────────┐  ┌──────────────────┐
│ foundDonation    │  │ errorMessage     │
│ = donation       │  │ = "No encontrada"│
│                  │  │                  │
└────────┬─────────┘  └────────┬─────────┘
         │                     │
         │                     │ Reinicia scanner
         │                     │ (startScanning())
         │                     │
         │                     └──→ Espera nuevo QR
         │
         ▼
┌─────────────────────────────────────────────────────────────────┐
│           📄 MOSTRAR DETALLES DE DONACIÓN                       │
│      (DonationDetailView en Sheet)                              │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │ [◀ Volver]                                                │ │
│  │                                                             │ │
│  │          FOLIO: D-12345                                   │ │
│  │                                                             │ │
│  │          [Imagen] [Imagen]                                │ │
│  │          [Imagen] [+1]                                    │ │
│  │                                                             │ │
│  │          Título: Ropa de invierno                         │ │
│  │          Estado: APROBADA ✅                              │ │
│  │                                                             │ │
│  │          Feedback del admin...                            │ │
│  │                                                             │ │
│  │          Bazar a entregar: Alameda                        │ │
│  │                                                             │ │
│  │          [Mapa]                                           │ │
│  │                                                             │ │
│  │          📱 Código QR                                     │ │
│  │             [QR Image]                                    │ │
│  │             Folio: D-12345                                │ │
│  │             [Copiar folio]                                │ │
│  └───────────────────────────────────────────────────────────┘ │
└─────────────────┬───────────────────────────────────────────────┘
                  │
                  │ Admin presiona "Volver"
                  │ O
                  │ Admin desliza hacia la derecha
                  ▼
┌─────────────────────────────────────────────────────────────────┐
│            ✅ CONFIRMAR ENTREGA (SWIPE)                         │
│      (BazarAdminDonationsView - SwipeActions)                  │
│                                                                 │
│  ┌─ Swipe → │ [Entregada ✓]                                   │
│  │                                                             │
│  │ "¿Confirmas que la donación fue entregada?"              │
│  │ [Cancelar]  [Marcar como entregada]                      │
│  └─────────────────────────────────────────────────────────────┘
                  │
                  │ Admin confirma entrega
                  ▼
┌─────────────────────────────────────────────────────────────────┐
│        💾 ACTUALIZAR EN FIRESTORE                               │
│    (BazarAdminDonationsVM.markAsDelivered)                     │
│                                                                 │
│  • db.collection("donations")                                  │
│    .document(id)                                               │
│    .updateData([                                               │
│      "isDelivered": true,                                      │
│      "deliveredAt": FieldValue.serverTimestamp()              │
│    ])                                                           │
└─────────────────┬───────────────────────────────────────────────┘
                  │
                  │ Se actualiza en Firestore
                  │ El listener refresca la UI
                  ▼
┌─────────────────────────────────────────────────────────────────┐
│            ✨ DONACIÓN MARCADA COMO ENTREGADA                   │
│                                                                 │
│  • Aparece en tab "Entregadas"                                 │
│  • Badge "Entregada" ✅ visible                                │
│  • Se mueve de la lista "Asignadas"                           │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔧 Componentes Técnicos

### 1. **QRScannerView** (UI Principal)
**Archivo:** `Views/QRScannerView.swift`

**Responsabilidades:**
- Mostrar interfaz de cámara
- Mostrar marco de escaneo
- Mostrar mensajes de estado
- Gestionar cierre de vista

**Estados:**
- `isLoading` - Cuando busca en Firestore
- `errorMessage` - Cuando falla la búsqueda o no encuentra
- `foundDonation` - Cuando encuentra la donación

---

### 2. **QRScannerViewController** (Captura de Cámara)
**Archivo:** `Views/QRScannerView.swift` (clase UIViewController)

**Responsabilidades:**
- Configurar sesión de captura de video (AVCaptureSession)
- Detectar códigos QR con AVCaptureMetadataOutput
- Implementar AVCaptureMetadataOutputObjectsDelegate
- Extraer contenido del QR

**Clave: `metadataOutput(_:didOutput:from:)`**
```swift
func metadataOutput(_ output: AVCaptureMetadataOutput,
                    didOutput metadataObjects: [AVMetadataObject],
                    from connection: AVCaptureConnection) {
    // Detecta QR y llama onQRDetected(stringValue)
}
```

**Antidebounce:**
- Previene múltiples detecciones del mismo QR
- Tiempo mínimo entre detecciones: 1 segundo

---

### 3. **QRScannerViewModel** (Lógica)
**Archivo:** `Views/QRScannerView.swift` (clase @MainActor)

**Responsabilidades:**
- Gestionar sesión de captura
- Solicitar permisos de cámara
- Manejar QR detectados
- Buscar donación en Firestore

**Métodos principales:**

```swift
// 1. Configurar sesión
setupCaptureSession()

// 2. Pedir permisos
requestCameraPermission()

// 3. Procesar QR
handleQRDetected(_ qrContent: String)
  ├─ isLoading = true
  ├─ fetchDonation(by: qrContent)
  ├─ Si existe → foundDonation = donation
  └─ Si no → errorMessage = "No encontrada"

// 4. Control de sesión
startScanning()   // Inicia captura
stopScanning()    // Detiene captura
```

---

### 4. **Integración con Firestore**
**FirestoreService:**

```swift
func fetchDonation(by id: String) async throws -> Donation? {
    let snapshot = try await db.collection("donations")
        .document(id)
        .getDocument()
    
    guard snapshot.exists else { return nil }
    return Donation.from(doc: snapshot)
}
```

**Qué busca:**
- ID de donación extraído del QR
- En colección "donations"
- Lee todos los campos incluyendo `qrCode`, `folio`, `status`, etc.

---

## 🔄 Flujo de Estados

```
INICIO
  │
  ├─→ requestCameraPermission()
  │   ├─ ✅ Permisos OK → setupCaptureSession()
  │   └─ ❌ Sin permisos → errorMessage
  │
  └─→ startScanning()
      │
      ├─→ AVCaptureSession.startRunning()
      │
      ├─ ESPERANDO QR
      │  │
      │  ├─ QR Detectado
      │  │  ├─ Vibración haptic
      │  │  ├─ captureSession.stopRunning()
      │  │  ├─ handleQRDetected(qrContent)
      │  │  │
      │  │  ├─ isLoading = true
      │  │  ├─ fetchDonation(by: qrContent)
      │  │  │
      │  │  ├─ ¿Encontrada?
      │  │  │  ├─ SÍ: foundDonation = donation
      │  │  │  │   └─ Muestra DonationDetailView
      │  │  │  │
      │  │  │  └─ NO: errorMessage = "No encontrada"
      │  │  │      └─ startScanning() (reinicia)
      │  │  │
      │  │  └─ isLoading = false
      │
      └─ CIERRE
         ├─ Usuario presiona X
         ├─ stopScanning()
         └─ Cierra sheet
```

---

## 📲 Flujo Usuario - Paso a Paso

### Escenario: Admin escanea donación entregada

1. **Admin abre app de bazar** → Ve lista "Asignadas"
2. **Presiona botón de cámara** 🎥 → Abre QRScannerView
3. **Sistema solicita permiso de cámara** → Admin acepta
4. **Cámara se activa** → Ve marco de escaneo
5. **Admin apunta al QR del usuario** 
6. **Sistema detecta QR** → Vibración
7. **Búsqueda en Firestore** → "Buscando donación..."
8. **Encontrada** → Abre DonationDetailView
9. **Admin ve detalles:**
   - Folio
   - Imágenes
   - Estado: APROBADA
   - Bazar destino
   - Ubicación
   - QR visible
10. **Admin hace swipe → Derecha** ➡️
11. **Botón "Entregada" ✓** → Presiona
12. **Confirmación:** "¿Confirmas?"
13. **Presiona "Marcar como entregada"**
14. **Firestore actualiza:** `isDelivered = true`
15. **Donación se mueve a "Entregadas"** ✅
16. **Admin puede cerrar y escanear otra**

---

## ⚙️ Configuración Técnica

### Permisos Requeridos (Info.plist)
```xml
<key>NSCameraUsageDescription</key>
<string>Se necesita acceso a la cámara para escanear códigos QR de donaciones</string>
```

### Frameworks Utilizados
- **AVFoundation** - Captura de video y detección de QR
- **CoreImage** - Generación de QR (en servicio separado)
- **Firebase/Firestore** - Almacenamiento y búsqueda
- **SwiftUI** - Interfaz de usuario

### Niveles de Corrección QR
- Nivel usado: **M (Modular)**
- Recuperación: ~15% de datos dañados
- Ideal para escaneo en movimiento

---

## 🐛 Manejo de Errores

| Error | Causa | Solución |
|-------|-------|----------|
| Sin permisos cámara | Usuario rechaza permiso | Se muestra alerta al usuario |
| "Donación no encontrada" | ID QR no existe en BD | Reinicia escáner para intentar otro |
| Timeout en Firestore | Conexión lenta/perdida | Se muestra error, puede reintentar |
| QR legible pero vacío | QR corrupto o vacío | Sistema valida contenido |
| Múltiples detecciones | QR en vista prolongada | Antidebounce (1 seg) evita duplicados |

---

## 🚀 Optimizaciones Implementadas

1. **Antidebounce:**
   - Previene múltiples detecciones
   - Controla tiempo mínimo (1 segundo)

2. **Sesión de captura optimizada:**
   - Se detiene automáticamente al detectar
   - Se reinicia si hay error

3. **Feedback haptic:**
   - Vibración al detectar QR
   - Mejor experiencia del usuario

4. **Lazy loading:**
   - DonationDetailView se abre en sheet
   - No bloquea interfaz principal

5. **Listeners reactivos:**
   - Cambios en Firestore se reflejan en tiempo real
   - UI se actualiza automáticamente

---

## 📱 Vista Previa de Pantallas

```
ANTES                          DURANTE ESCANEO              DESPUÉS
┌──────────────────┐          ┌──────────────────┐         ┌──────────────────┐
│ ✏️ Asignadas (5) │    →     │ [X] Escanear QR  │   →    │ ✨ Entregadas (1)│
│                  │          │                  │         │                  │
│ 📦 Ropa          │          │    📸 CÁMARA     │         │ 📦 Ropa ✅       │
│ 📦 Muebles       │          │                  │         │ 📦 Electro       │
│ 📦 Electro       │          │  ┌─────────────┐ │         │ 📦 Muebles ✅    │
│ 📦 Libros        │          │  │  MARCO QR   │ │         │                  │
│ 📦 Ropa 2        │          │  └─────────────┘ │         │                  │
└──────────────────┘          └──────────────────┘         └──────────────────┘
                                       │
                                  QR Detectado
                                       │
                                       ▼
                              ┌──────────────────┐
                              │  FOLIO: D-12345  │
                              │                  │
                              │  [Imágenes]      │
                              │  Ropa de invierno│
                              │  APROBADA ✅     │
                              │                  │
                              │  🔄 SWIPE →     │
                              │  ✓ Entregada    │
                              └──────────────────┘
```

---

## 🔐 Seguridad

- ✅ Solo admins de bazar pueden escanear
- ✅ QR solo funciona para donaciones aprobadas
- ✅ Registro en Firestore de cada entrega (`deliveredAt`)
- ✅ No se puede marcar como entregada sin escanear
- ✅ Validación de permisos de cámara

---

## 📊 Resumen de Archivos Involucrados

| Archivo | Responsabilidad |
|---------|-----------------|
| `QRScannerView.swift` | UI + ViewController + ViewModel del escáner |
| `BazarAdminDonationsView.swift` | Botón para abrir escáner + Sheet |
| `DonationDetailView.swift` | Muestra detalles después de escanear |
| `FIrestoreService.swift` | `fetchDonation(by:)` para buscar |
| `Models/Models.swift` | Modelo `Donation` con campos QR |
| `Info.plist` | Permisos de cámara |

---

## ✅ Checklist de Funcionamiento

- [x] QR se genera al aprobar donación
- [x] Botón de cámara visible en barra de herramientas
- [x] Permisos de cámara solicitados
- [x] QR detectado correctamente
- [x] Búsqueda en Firestore funciona
- [x] Donación se muestra en sheet
- [x] Swipe to mark delivered funciona
- [x] Estado se actualiza en Firestore
- [x] UI se refresca automáticamente
- [x] Manejo de errores completo
