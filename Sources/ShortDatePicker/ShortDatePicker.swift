import UIKit
@objc class ShortDatePickerView: UIPickerView {
    enum Component: Int {
        case month = 0
        case year = 1
    }
    let labelTag = 43
    let bigRowCount = 1000
    let numberOfComponentsRequired = 2
    var months: [String] = []
    var years: [String] = []
    var bigRowMonthsCount: Int {
        return bigRowCount * months.count
    }
    var bigRowYearsCount: Int {
        return bigRowCount * years.count
    }
    var monthSelectedTextColor: UIColor?
    var monthTextColor: UIColor?
    var yearSelectedTextColor: UIColor?
    var yearTextColor: UIColor?
    var monthSelectedFont: UIFont?
    var monthFont: UIFont?
    var yearSelectedFont: UIFont?
    var yearFont: UIFont?
    let rowHeight: Int = 44
    /**
     Will be returned in user's current TimeZone settings
     **/
    var date: Date {
        let month = self.months[selectedRow(inComponent: Component.month.rawValue)]
        let year = self.years[selectedRow(inComponent: Component.year.rawValue)]
        let formatter = DateFormatter()
        formatter.dateFormat = "MM yyyy"
        return formatter.date(from: "\(month) \(year)")!
    }
    var minYear: Int!
    var maxYear: Int!
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadDefaultParameters()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadDefaultParameters()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        loadDefaultParameters()
    }
    fileprivate func currentYearMonths() {
        let month = Calendar.current.dateComponents([.month], from: Date())
        for varI in (month.month ?? 0)...12 {
            months.append("\(varI)")
        }
    }
    func loadDefaultParameters() {
        minYear = Calendar.current.dateComponents([.year], from: Date()).year
        maxYear = minYear! + 10
        delegate = self
        dataSource = self
        monthTextColor = .black
        yearTextColor = .black
        monthSelectedFont = .boldSystemFont(ofSize: 17)
        monthFont = .boldSystemFont(ofSize: 17)
        yearSelectedFont = .boldSystemFont(ofSize: 17)
        yearFont = .boldSystemFont(ofSize: 17)
        for varI in minYear...maxYear {
            years.append("\(varI)")
        }
        currentYearMonths()
    }
    func setup(minYear: Int, andMaxYear maxYear: Int) {
        self.minYear = minYear
        if maxYear > minYear {
            self.maxYear = maxYear
        } else {
            self.maxYear = minYear + 10
        }
    }
    func selectToday() {
        selectRow(todayIndexPath.row, inComponent: Component.month.rawValue, animated: false)
        selectRow(todayIndexPath.section, inComponent: Component.year.rawValue, animated: false)
    }
    var todayIndexPath: IndexPath {
        var row = 0.0
        var section = 0.0
        for cellMonth in months  where cellMonth == currentMonthName {
            row = Double(months.firstIndex(of: cellMonth)!)
            row += Double(bigRowMonthsCount / 2)
            break
        }
        for cellYear in years where cellYear == currentYearName {
            section = Double(years.firstIndex(of: cellYear)!)
            section += Double(bigRowYearsCount / 2)
            break
        }
        return IndexPath(row: Int(row), section: Int(section))
    }
    var currentMonthName: String {
        let formatter = DateFormatter()
        let locale = Locale.init(identifier: "en_US")
        formatter.locale = locale
        formatter.dateFormat = "MM"
        return formatter.string(from: Date())
    }
    var currentYearName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: Date())
    }
    func selectedColorForComponent(component: Int) -> UIColor {
        component == Component.month.rawValue ?
        monthSelectedTextColor! : yearSelectedTextColor!
    }
    func colorForComponent(component: Int) -> UIColor {
        component == Component.month.rawValue ?
        monthTextColor! : yearTextColor!
    }
    func selectedFontForComponent(component: Int) -> UIFont {
        component == Component.month.rawValue ?
        monthSelectedFont! : yearSelectedFont!
    }
    func fontForComponent(component: Int) -> UIFont {
        component == Component.month.rawValue ? monthFont! : yearFont!
    }
    func titleForRow(row: Int, forComponent component: Int) -> String? {
        component == Component.month.rawValue ? months[row] : years[row]
    }
    func labelForComponent(component: NSInteger) -> UILabel {
        let frame = CGRect(x: 0.0, y: 0.0, width: bounds.size.width, height: CGFloat(rowHeight))
        let label = UILabel(frame: frame)
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.isUserInteractionEnabled = false
        label.tag = labelTag
        return label
    }
}
extension ShortDatePickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        numberOfComponentsRequired
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        component == Component.month.rawValue ? months.count : years.count
    }
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        bounds.size.width / CGFloat(numberOfComponentsRequired)
    }
    func pickerView(_ pickerView: UIPickerView,
                    viewForRow row: Int,
                    forComponent component: Int,
                    reusing view: UIView?) -> UIView {
        var selected = pickerView.selectedRow(inComponent: component) == row
        if component == Component.month.rawValue {
            let monthName = self.months[row]
            if monthName == currentMonthName {
                selected = true
            }
        } else {
            let yearName = self.years[row ]
            if yearName == currentYearName {
                selected = true
            }
        }
        var returnView: UILabel
        if let view = view, view.tag == labelTag, let returnV = view as? UILabel {
            returnView = returnV
        } else {
            returnView = labelForComponent(component: component)
        }
        returnView.font = selected ?
        selectedFontForComponent(component: component) :
        fontForComponent(component: component)
        returnView.text = titleForRow(row: row, forComponent: component)
        return returnView
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        CGFloat(rowHeight)
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        2
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 1 {
            if row == 0 {
                months.removeAll()
                currentYearMonths()
            } else {
                months.removeAll()
                for varI in 1...12 {
                    months.append("\(varI)")
                }
            }
            pickerView.reloadComponent(0)
        }
    }
}
