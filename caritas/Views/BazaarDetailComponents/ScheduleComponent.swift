//
//  ScheduleComponent.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 09/11/25.
//

import SwiftUI

struct ScheduleComponent: View {
    
    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_MX")
        return f
    }()
    
    let horario: String
    
    var body: some View {
        
        let abiertoEntreSemanaAhora = isOpenOnWeekdaysNow(horario: horario)
        
        VStack(alignment: .leading) {
            
            HStack{
                Text("Horarios")
                    .font(.gotham(.bold, style: .headline))
                
                Spacer()
                
                Text(abiertoEntreSemanaAhora ? "Abierto" : "Cerrado")
                    .font(.gotham(.bold, style: .subheadline))
                    .foregroundStyle(.white)
                    .padding(7)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(abiertoEntreSemanaAhora ? .green.opacity(0.75) : .red.opacity(0.75))
                            
                    )
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 10){
                ForEach(getHorarios(horario: horario), id: \.self) { h in
                    Text(h)
                        .font(.subheadline)
                }
            }
            .padding(.top, 8)
            .padding(.horizontal, 32)
        }
    }
    
    // MARK: - Fecha
    func getDay() -> String {
        let hoy = Date()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: hoy)
    }
    // MARK: - Hora
    func getHour() -> String {
        let hoy = Date()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: hoy)
    }
    
    // MARK: - División del texto en bloques por ';'
    func getHorarios(horario: String) -> [String] {
        horario
            .components(separatedBy: ";")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    // MARK: - Lógica: ¿está abierto entre semana ahora?
    func isOpenOnWeekdaysNow(horario: String) -> Bool {
        // Solo nos importa el bloque "Lunes a Viernes ..."
        guard let bloqueLV = getHorarios(horario: horario).first(where: { $0.localizedCaseInsensitiveContains("Lunes a Viernes") }) else {
            return false
        }
        
        // Extraer dos horas (ej. "9:00 a.m.", "6:00 p.m.")
        let horas = extractTimes(from: bloqueLV) // en minutos desde medianoche
        guard horas.count >= 2 else { return false }
        let (start, end) = (horas[0], horas[1])
        
        // Día actual (1=domingo, 2=lunes, ..., 7=sábado)
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: Date())
        let isWeekday = (2...6).contains(weekday) // lunes a viernes
        
        // Minutos actuales desde medianoche
        let now = Date()
        let hour = cal.component(.hour, from: now)
        let minute = cal.component(.minute, from: now)
        let nowMinutes = hour * 60 + minute
        
        return isWeekday && nowMinutes >= start && nowMinutes <= end
    }
    
    // MARK: - Utilidades para parsear horas en español ("9:00 a.m.", "6:00 p.m.")
    /// Devuelve un arreglo de tiempos encontrados en `texto`, expresados en minutos desde medianoche.
    func extractTimes(from texto: String) -> [Int] {
        // Normaliza varias formas: "a.m.", "a. m.", "am", etc.
        let normalized = normalizeMeridiem(in: texto)
        
        // Encuentra patrones "H:MM" o "HH:MM" seguidos de "am"/"pm"
        // Usamos una expresión simple para obtener "h:mm" y luego vemos el sufijo.
        // Ej: "9:00 am", "6:00 pm"
        let pattern = #"(\d{1,2}):(\d{2})\s?(am|pm)"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return []
        }
        
        let ns = normalized as NSString
        let matches = regex.matches(in: normalized, range: NSRange(location: 0, length: ns.length))
        
        var result: [Int] = []
        for m in matches {
            if m.numberOfRanges == 4,
               let hRange = Range(m.range(at: 1), in: normalized),
               let mRange = Range(m.range(at: 2), in: normalized),
               let aRange = Range(m.range(at: 3), in: normalized) {
                
                let hStr = String(normalized[hRange])
                let minStr = String(normalized[mRange])
                let ampm = String(normalized[aRange]).lowercased()
                
                if let h = Int(hStr), let mins = Int(minStr) {
                    let total = toMinutesSinceMidnight(hour: h, minute: mins, ampm: ampm)
                    result.append(total)
                }
            }
        }
        return result
    }
    
    /// Convierte diversas variantes "a.m./p.m." en "am"/"pm" y poda espacios extra.
    func normalizeMeridiem(in text: String) -> String {
        var s = text.lowercased()
        s = s.replacingOccurrences(of: "a. m.", with: "am")
            .replacingOccurrences(of: "a.m.", with: "am")
            .replacingOccurrences(of: "a m", with: "am")
            .replacingOccurrences(of: " am", with: " am")
        
        s = s.replacingOccurrences(of: "p. m.", with: "pm")
            .replacingOccurrences(of: "p.m.", with: "pm")
            .replacingOccurrences(of: "p m", with: "pm")
            .replacingOccurrences(of: " pm", with: " pm")
        
        s = s.replacingOccurrences(of: #"([0-9])am"#, with: "$1 am", options: .regularExpression)
        s = s.replacingOccurrences(of: #"([0-9])pm"#, with: "$1 pm", options: .regularExpression)
        return s
    }
    
    func toMinutesSinceMidnight(hour: Int, minute: Int, ampm: String) -> Int {
        var h24 = hour % 12 // 12 am/pm se normaliza a 0 y luego ajustamos
        if ampm == "pm" { h24 += 12 }
        // 12am -> 0, 12pm -> 12, 1pm -> 13, etc.
        return h24 * 60 + minute
    }
}

#Preview {
    ScheduleComponent(horario: "Lunes a Viernes 9:00 a.m. a 6:00 p.m.; Sábado 10:00 a.m. a 6:00 p.m.")
}
