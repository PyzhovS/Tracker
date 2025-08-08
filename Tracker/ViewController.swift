
import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Hello, AutoLayout!"
        label.font =
        .systemFont(ofSize: 20)
        label.sizeToFit()
        label.textAlignment =
        .center
        view.backgroundColor = .white
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
       
    }
    


}

