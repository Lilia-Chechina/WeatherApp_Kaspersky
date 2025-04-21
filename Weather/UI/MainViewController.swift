import UIKit

class MainViewController: UIViewController {
    
    // MARK: - Private Types
    
    private typealias Item = CityTableCellViewModel
    
    // MARK: - Private Properties
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet private weak var tableView: UITableView!
    
    private lazy var weatherService: WeatherService = {
        WeatherServiceImpl()
    }()
    
    private lazy var lastSearchCitiesProvider: LastSearchCitiesProvider = {
        LastSearchCitiesProviderImpl()
    }()
    
    private var items: [Item] = []
    
    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        loadLastSearchedCities()
    }
    
    // MARK: - Private Methods
    
    private func loadLastSearchedCities() {
        let cities = lastSearchCitiesProvider.lastSearchedCities
        
        let group = DispatchGroup()
        var newItems: [CityTableCellViewModel] = []
        
        for city in cities {
            group.enter()
            weatherService.getCurrentWeather(city: city) { result in
                if case .success(let model) = result {
                    newItems.append(CityTableCellViewModel(cityModel: model))
                }
                group.leave()
            }
        }
        group.notify(queue: .main) { [weak self] in
            self?.items = newItems
            self?.tableView.reloadData()
        }
    }
    
    private func searchCity(_ city: String) {
        // Here you should process Add New City
        // Отсюда мой код:
        let trimmed = city.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        // Проверка на дубликат
        if items.contains(where: { $0.name?.lowercased() == trimmed.lowercased() }) {
            print("Город уже добавлен")
            return
        }
        
        weatherService.getCurrentWeather(city: trimmed) { [weak self] result in
            guard let self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    let viewModel = CityTableCellViewModel(cityModel: model)
                    self.items.insert(viewModel, at: 0)
                    self.lastSearchCitiesProvider.addCity(trimmed)
                    self.tableView.reloadData()
                    
                case .failure(let error):
                    if case .cityNotFound = error {
                        self.showAlert(title: "Город не найден", message: "")
                    } else {
                        self.showAlert(title: "Ошибка", message: "Не удалось загрузить данные")
                    }
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func setupTableView() {
        tableView.register(CityTableCell.nib, forCellReuseIdentifier: CityTableCell.reuseIdentifier)
    }
    
    private func cellModel(at indexPath: IndexPath) -> Item? {
        let numberOfItems = items.count
        guard indexPath.row >= 0 && indexPath.row < numberOfItems else {
            print("View model section <\(indexPath.section)> contains <\(numberOfItems)> cells. Got request for a cell at index <\(indexPath.row)>")
            return nil
        }
        return items[indexPath.row]
    }
    
}

extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = CityTableCell.reuseIdentifier
        let tableCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        guard let cityTableCell = tableCell as? CityTableCell else {
            print("Unable to cast tableCell to CityTableCell")
            return tableCell
        }
        
        guard let cellModel = cellModel(at: indexPath) else {
            print("Unable to get cell model at indexPath <\(indexPath)>")
            return tableCell
        }
        
        cityTableCell.configure(with: cellModel)
        
        return cityTableCell
    }
    
}

extension MainViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchCity(searchBar.text ?? "")
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()
    }
    
}
