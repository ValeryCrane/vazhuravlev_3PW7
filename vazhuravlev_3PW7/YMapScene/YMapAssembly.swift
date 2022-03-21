//
//  YMapAssembly.swift
//  vazhuravlev_3PW7
//
//  Created by Валерий Журавлев on 18.03.2022.
//

import Foundation
import UIKit

// Assembles YMapKitScene
class YMapAssembly {
    func assemble() -> UIViewController {
        let view = YMapViewController()
        let interactor = YMapInteractor()
        let presenter = YMapPresenter()
        
        view.interactor = interactor
        interactor.presenter = presenter
        presenter.view = view
        
        return view
    }
}
