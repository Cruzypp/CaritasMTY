//
//  CategorySelectionView.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 07/11/25.
//

import SwiftUI
import Combine

final class CategorySelectorVM: ObservableObject {
    @Published var seleccionadas: Set<DonateViewModel.Categoria> = []
    let maxSelection: Int?    // nil = sin límite
    
    init(maxSelection: Int? = nil) {
        self.maxSelection = maxSelection
    }
    
    func toggle(_ c: DonateViewModel.Categoria) {
        if seleccionadas.contains(c) {
            seleccionadas.remove(c)
        } else {
            if let max = maxSelection, seleccionadas.count >= max { return }
            seleccionadas.insert(c)
        }
    }
}

import SwiftUI

// Un layout que envuelve vistas ("chips") a la siguiente línea según el ancho disponible
struct FlowLayout: Layout {
    var spacingX: CGFloat = 8
    var spacingY: CGFloat = 8
    var alignment: HorizontalAlignment = .leading

    func sizeThatFits(proposal: ProposedViewSize,
                      subviews: Subviews,
                      cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x > 0 && x + size.width > maxWidth {
                // Nueva fila
                x = 0
                y += rowHeight + spacingY
                rowHeight = 0
            }
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacingX
        }
        return CGSize(width: maxWidth.isFinite ? maxWidth : x,
                      height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect,
                       proposal: ProposedViewSize,
                       subviews: Subviews,
                       cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)

            if x > bounds.minX && x + size.width > bounds.maxX {
                // Nueva fila
                x = bounds.minX
                y += rowHeight + spacingY
                rowHeight = 0
            }

            sub.place(at: CGPoint(x: x, y: y),
                      proposal: ProposedViewSize(width: size.width, height: size.height))

            x += size.width + spacingX
            rowHeight = max(rowHeight, size.height)
        }
    }
}


struct CategorySelectorView: View {
    @ObservedObject var vm = CategorySelectorVM()
    let categorias: [DonateViewModel.Categoria] = DonateViewModel.Categoria.allCases
    
    // Grid adaptable: se refluye como “chips”
    private let columns = [
        GridItem(.adaptive(minimum: 120), spacing: 10, alignment: .leading)
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Categorías")
                .font(.gotham(.bold, style: .headline))
            FlowLayout(spacingX: 10, spacingY: 12) {
                ForEach(categorias, id: \.self) { cat in
                    CategoryPill(
                        categoria: cat,
                        isSelected: vm.seleccionadas.contains(cat),
                        action: { vm.toggle(cat) }
                    )
                }
            }
            .padding()
        }
        .padding()
    }
}

// 5) Ejemplo de uso
struct CategorySelectorPreview: View {
    @StateObject var vm = CategorySelectorVM(maxSelection: 10)
    
    var body: some View {
        NavigationStack {
            CategorySelectorView(vm: vm)
        }
    }
}

#Preview {
    CategorySelectorPreview()
}
