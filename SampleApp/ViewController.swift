//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//

import Cyborg
import UIKit

class Theme: Cyborg.ValueProviding {

    func colorFromTheme(named _: String) -> UIColor {
        return .black
    }

    func colorFromResources(named _: String) -> UIColor {
        return .black
    }

}

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let drawableData = [
            baselinesplit,
        ]
        .map { data in
            data.data(using: .utf8)!
        }
        for data in drawableData {
            let vectorView = VectorView(externalValues: Theme())
            view.addSubview(vectorView)
            vectorView.translatesAutoresizingMaskIntoConstraints = false
            let result = VectorDrawable.create(from: data)
            switch result {
            case .ok(let drawable):
                vectorView.drawable = drawable
            case .error(let error):
                print(error)
                fatalError(error)
            }
            NSLayoutConstraint
                .activate([
                    vectorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    vectorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//                    vectorView.widthAnchor.constraint(equalToConstant: 300),
//                    vectorView.heightAnchor.constraint(equalToConstant: 300)
                ])
        }
    }
}
