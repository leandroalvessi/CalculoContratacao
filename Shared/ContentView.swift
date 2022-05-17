//
//  ContentView.swift
//  Shared
//
//  Created by Leandro Alves da Silva on 29/03/22.
//

import SwiftUI
import UIKit

class CurrencyUITextField: UITextField {
    
    @Binding private var value: Double
    private let formatter: NumberFormatter
    
    init(formatter: NumberFormatter, value: Binding<Double>) {
        self.formatter = formatter
        self._value = value
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        addTarget(self, action: #selector(resetSelection), for: .allTouchEvents)
        keyboardType = .numberPad
        textAlignment = .right
        sendActions(for: .editingChanged)
    }
    
    override func deleteBackward() {
        text = textValue.digits.dropLast().string
        sendActions(for: .editingChanged)
    }
    
    private func setupViews() {
        tintColor = .clear
        font = .systemFont(ofSize: 30, weight: .regular)
    }
    
    @objc private func editingChanged() {
        text = currency(from: decimal)
        resetSelection()
        value = doubleValue
    }
    
    @objc private func resetSelection() {
        selectedTextRange = textRange(from: endOfDocument, to: endOfDocument)
    }
    
    private var textValue: String {
        return text ?? ""
    }
    
    private var doubleValue: Double {
        return (decimal as NSDecimalNumber).doubleValue
    }
    
    private var decimal: Decimal {
        return textValue.decimal / pow(10, formatter.maximumFractionDigits)
    }
    
    private func currency(from decimal: Decimal) -> String {
        return formatter.string(for: decimal) ?? ""
    }
}

extension StringProtocol where Self: RangeReplaceableCollection {
    var digits: Self { filter (\.isWholeNumber) }
}

extension String {
    var decimal: Decimal { Decimal(string: digits) ?? 0 }
}

extension LosslessStringConvertible {
    var string: String { .init(self) }
}

struct CurrencyTextField: UIViewRepresentable {
    
    typealias UIViewType = CurrencyUITextField
    
    let numberFormatter: NumberFormatter
    let currencyField: CurrencyUITextField
    
    init(numberFormatter: NumberFormatter, value: Binding<Double>) {
        self.numberFormatter = numberFormatter
        currencyField = CurrencyUITextField(formatter: numberFormatter, value: value)
    }
    
    func makeUIView(context: Context) -> CurrencyUITextField {
        return currencyField
    }
    
    func updateUIView(_ uiView: CurrencyUITextField, context: Context) { }
}

class NumbersOnly: ObservableObject {
    @Published var value = "" {
        didSet {
            let filtered = value.filter { $0.isNumber }
            
            if value != filtered {
                value = filtered
            }
        }
    }
}

struct ContentView: View {
    @State private var isSubtitleHidden = false
    @State private var value = 0.0
    @State private var per = 20
    
    private var numberFormatter: NumberFormatter
    
    init(numberFormatter: NumberFormatter = NumberFormatter()) {
        self.numberFormatter = numberFormatter
        self.numberFormatter.numberStyle = .currency
        self.numberFormatter.maximumFractionDigits = 2
    }
    
    var body: some View {
        NavigationView {
            VStack {
                CurrencyTextField(numberFormatter: numberFormatter, value: $value)
                    .padding(20)
                    .frame(height: 40)
                Stepper("Percentual: \(per)", onIncrement: {
                    per += 1
                }, onDecrement: {
                    per -= 1
                }).padding(20)
                NavigationLink(
                    destination: Screen(value: value, per: per),
                    label: {
                        Calcular(color: .green )
                    }
                )
                
            }.frame(width: .infinity, height: 0, alignment: .bottom)
                .navigationTitle("Cálculo Contratação")//.padding()
        }
    }
}

struct Calcular: View {
    let color: Color
    
    var body: some View {
        Text("Calcular")
            .frame(width: 200, height: 50, alignment: .center)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
}

struct Screen: View {
    let value: Double
    let per: Int
    
    var body: some View {
        VStack {
            let InssEmpregadorViaClt = (value * 28) / 100
            let InssEmpregadorContratadoAutonomo = (value * Double(per)) / 100
            let Fgts = (value * 8) / 100
            let Decimo13SalarioViaClt = (value * 11.33) / 100
            let Decimo13SalarioFgtsInssSimplesClt = (value * 9) / 100
            let FeriasViaClt = (value * 15.07) / 100
            let FeriasSimplesClt = (value * 11.97) / 100
//            let ProvisaoMultaFgts = (((value * 8) / 100) * 40) / 100
//            let CustoTotalContratanteViaClt = ((value * 66) / 100) + value
//            let CustoTotalContratanteSimplesClt = ((value * 32) / 100) + value
//            let CustoTotalContratanteContratoAutonomo = ((value * Double(per)) / 100) + value
//            let SimpesContratadpPjSimples = (value * 4.5) / 100
//            let IssContratadoAutonomo = (value * 5) / 100
//            let PisCofinsIrpjContratadoPj = (value * 11.33) / 100
//
//            var InssDescontoContratado = 0.0
//            var InssDescontoContratadoAux = 0.0
//            var InssDescontoContratadoDeduz = 0.0
//            var PerInss = 0
//            if value <= 1659.38 {
//                PerInss = 8
//                InssDescontoContratado = (value * Double(PerInss)) / 100
//                InssDescontoContratadoDeduz = (value * Double(PerInss)) / 100
//                InssDescontoContratadoAux = value - ((value * Double(PerInss)) / 100)
//            } else if (value >= 1659.39) && (value <= 2765.66) {
//                PerInss = 9
//                InssDescontoContratado = (value * Double(PerInss)) / 100
//                InssDescontoContratadoDeduz = (value * Double(PerInss)) / 100
//                InssDescontoContratadoAux = value - ((value * Double(PerInss)) / 100)
//            } else if (value >= 2765.67) && (value <= 5531.31) {
//                PerInss = 11
//                InssDescontoContratado = (value * Double(PerInss)) / 100
//                InssDescontoContratadoDeduz = (value * Double(PerInss)) / 100
//                InssDescontoContratadoAux = value - ((value * Double(PerInss)) / 100)
//            } else if value > 5531.32 {
//                InssDescontoContratado = 604.44
//                InssDescontoContratadoDeduz = 604.44
//                InssDescontoContratadoAux = value - 604.44
//            }
//
//            let PerInssString = PerInss != 0 ? String(PerInss) + "%, " : ""
//
//            var IrrfDescontoContratado = 0.0
//            var PerIrrf = 0.0
//            var Deduz = 0.0
//            if InssDescontoContratadoAux <= 1903.99 {
//                IrrfDescontoContratado = value - InssDescontoContratadoAux / 100
//            } else if (InssDescontoContratadoAux >= 1904.00) && (InssDescontoContratadoAux <= 2826.65) {
//                PerIrrf = 7.5
//                Deduz = 142.80
//                IrrfDescontoContratado = ((InssDescontoContratadoAux * PerIrrf) / 100) - Deduz
//            } else if (InssDescontoContratadoAux >= 2826.66) && (InssDescontoContratadoAux <= 3751.05) {
//                PerIrrf = 15
//                Deduz = 354.80
//                IrrfDescontoContratado = ((InssDescontoContratadoAux * PerIrrf) / 100) - Deduz
//            } else if (InssDescontoContratadoAux >= 3751.06) && (InssDescontoContratadoAux <= 4664.68) {
//                PerIrrf = 22.5
//                Deduz = 636.13
//                IrrfDescontoContratado = ((InssDescontoContratadoAux * PerIrrf) / 100) - Deduz
//            } else if InssDescontoContratadoAux > 4664.69{
//                PerIrrf = 27.5
//                Deduz = 869.36
//                IrrfDescontoContratado = ((InssDescontoContratadoAux * PerIrrf) / 100) - Deduz
//            }
//
//            let PerIrrfString = PerIrrf != 0 ? String(PerIrrf) + "%, " : ""
            
            
            let cabecalhos: [Header] = [
                Header(name: "INSS Empregador",
                       detalhes: [Detalhe(name: "LP/LR VIA CLT: 28%, " + NumberFormatter.localizedString(from: InssEmpregadorViaClt as NSNumber, number: .currency)),
                                  Detalhe(name: "Contratado Autônomo: \(per)%, " + NumberFormatter.localizedString(from: InssEmpregadorContratadoAutonomo as NSNumber, number: .currency))]),
                Header(name: "FGTS",
                       detalhes: [Detalhe(name: "LP/LR VIA CLT: 8%, " + NumberFormatter.localizedString(from: Fgts as NSNumber, number: .currency)),
                                  Detalhe(name: "Simples CLT: 8%, " + NumberFormatter.localizedString(from: Fgts as NSNumber, number: .currency))]),
                Header(name: "13º Salário + Encargos FGTS e INSS",
                       detalhes: [Detalhe(name: "LP/LR VIA CLT: 11,33%, " + NumberFormatter.localizedString(from: Decimo13SalarioViaClt as NSNumber, number: .currency)),
                                  Detalhe(name: "Simples CLT: 9%, " + NumberFormatter.localizedString(from: Decimo13SalarioFgtsInssSimplesClt as NSNumber, number: .currency))]),
                Header(name: "Férias + 1/3 + Encargos FGTS e INSS",
                       detalhes: [Detalhe(name: "LP/LR VIA CLT: 11,33%, " + NumberFormatter.localizedString(from: FeriasViaClt as NSNumber, number: .currency)),
                                  Detalhe(name: "Simples CLT: 9%, " + NumberFormatter.localizedString(from: FeriasSimplesClt as NSNumber, number: .currency))])
            ]
            
            
            List {
                ForEach(cabecalhos) { region in
                    Section(header: Text(region.name)) {
                        ForEach(region.detalhes) { detalhe in
                            Text(detalhe.name)
                        }
                    }
                }
            }
        }
    }
    
}

struct Detalhe: Hashable, Identifiable {
    let name: String
    let id = UUID()
}

struct Header: Identifiable {
    let name: String
    let detalhes: [Detalhe]
    let id = UUID()
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
