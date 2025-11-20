# Sistema de Código QR para Donaciones - Resumen de Implementación

## Descripción General

Se ha implementado un sistema completo de códigos QR para optimizar el flujo de entrega de donaciones en los bazares de Cáritas. El sistema genera automáticamente un QR cuando una donación es aprobada, permite que los usuarios vean su QR, y facilita a los administradores del bazar escanear el QR para confirmar rápidamente la entrega.

## Cambios Realizados

### 1. **Modelo de Datos (Models.swift)**
- Agregados dos nuevos campos al modelo `Donation`:
  - `qrCode: String?` - Almacena el código QR en formato base64
  - `qrGeneratedAt: Timestamp?` - Registra cuándo se generó el QR
- Actualizado `from(doc:)` para leer estos campos desde Firestore
- Actualizado `toDict()` para escribir estos campos en Firestore

### 2. **Servicio de Generación de QR (Services/QRGenerationService.swift)**
Nuevo archivo que proporciona:
- Método `generateQRCode(for donationId: String) -> String?`
- Genera un QR basado en el ID de la donación
- Retorna la imagen en formato base64 (PNG)
- Usa `CIQRCodeGenerator` de CoreImage con nivel de corrección "M"

### 3. **Servicio Firestore Actualizado (Services/FIrestoreService.swift)**
- Nuevo método `approveDonationWithQR()`:
  - Genera el QR automáticamente
  - Aprueba la donación en Firestore
  - Almacena el QR y la fecha de generación
- Nuevo método `fetchDonation(by id:)`:
  - Obtiene una donación específica por ID
  - Usado para resolver el QR escaneado

### 4. **Vista de Mostrar QR (Views/DonationDetailComponents/QRDisplayView.swift)**
Nueva vista que muestra:
- El código QR generado (imagen decodificada desde base64)
- Número de folio de la donación
- Instrucciones para el usuario
- Botón para copiar el folio al portapapeles

### 5. **Vista de Escaneo QR (Views/QRScannerView.swift)**
Nueva vista completa de escaneo que incluye:
- **QRScannerView**: Vista principal con interfaz
- **QRScannerCameraView**: Representable de UIViewController
- **QRScannerViewController**: Controlador que maneja la captura de video y detección de QR
- **QRScannerViewModel**: Lógica de escaneo y búsqueda de donaciones

Características:
- Interfaz clara con marco de escaneo
- Feedback haptic al detectar QR
- Prevención de detecciones múltiples en corto tiempo
- Búsqueda automática de la donación en Firestore
- Muestra la donación encontrada en una sheet
- Manejo de errores y estados de carga

### 6. **Integración en BazarAdminDonationsView**
- Agregado botón de escaneo QR (ícono: qrcode.viewfinder)
- Estado `@State private var showQRScanner = false`
- Sheet que presenta `QRScannerView`
- Botón ubicado junto a configuración en la barra de herramientas

### 7. **Integración en DonationDetailView**
- Mostrado `QRDisplayView` cuando:
  - La donación está aprobada AND
  - Existe un QR generado
- Ubicado después de la sección de ubicación

### 8. **Actualización de ViewModels**

**AdminReviewsViewModel**:
- Agregados métodos `approveDonation()` y `rejectDonation()`
- Usa `approveDonationWithQR()` para aprobar

**AdminDonationDetailVM** (en AdminDonationDetailView.swift):
- Actualizado `updateStatus()` para usar `approveDonationWithQR()` cuando aprueba
- Mantiene compatibilidad con rechazo usando `setDonationStatus()`

### 9. **Configuración de Permisos (Info.plist)**
Agregada entrada obligatoria:
```xml
<key>NSCameraUsageDescription</key>
<string>Se necesita acceso a la cámara para escanear códigos QR de donaciones</string>
```

## Flujo de Uso

### Para Usuarios Donantes:
1. Usuario crea una donación
2. Administrador de calidad revisa y aprueba → Se genera automáticamente un QR
3. Usuario ve su donación aprobada con el QR visible
4. Usuario muestra el QR al llegar al bazar

### Para Administradores de Bazar:
1. Están viendo la lista de donaciones asignadas
2. Presionan el botón de escaneo QR (ícono de cámara)
3. Se abre el escáner
4. Acercan el QR a la cámara
5. Sistema automáticamente busca la donación
6. Se abre la vista de detalles de la donación
7. Pueden confirmar la entrega con un swipe

## Archivos Modificados
- `Models/Models.swift` ✅
- `Services/FIrestoreService.swift` ✅
- `Views/DonationDetailView.swift` ✅
- `Views/BazarAdminDonationsView.swift` ✅
- `Views/AdminDonationDetailView.swift` ✅
- `ViewModels/AdminReviewsViewModel.swift` ✅
- `Info.plist` ✅

## Archivos Nuevos
- `Services/QRGenerationService.swift` ✅
- `Views/QRScannerView.swift` ✅
- `Views/DonationDetailComponents/QRDisplayView.swift` ✅

## Ventajas del Sistema

1. **Eficiencia**: Eliminación de búsquedas manuales de donaciones
2. **Automatización**: QR se genera automáticamente al aprobar
3. **Seguridad**: Solo se pueden confirmar entregas de donaciones aprobadas
4. **Experiencia**: Interfaz clara para escaneo y visualización
5. **Escalabilidad**: Sistema listo para expansión con más bazares

## Consideraciones Técnicas

- QR generado en base64 para almacenamiento en Firestore
- Usa nivel de corrección de errores "M" (modular)
- El contenido del QR es el ID único de la donación
- Escáner implementado con `AVFoundation`
- Feedback haptic para mejor UX
- Manejo de permisos de cámara con `AVCaptureDevice.requestAccess()`

## Pruebas Recomendadas

1. ✅ Verificar que el QR se genera cuando se aprueba
2. ✅ Confirmar que el QR es legible por lectores estándar
3. ✅ Probar escaneo en diferentes ángulos y distancias
4. ✅ Verificar funcionamiento con y sin permisos de cámara
5. ✅ Probar navegación desde QR escaneado a detalle de donación
6. ✅ Confirmar que solo donaciones aprobadas con QR se muestran
