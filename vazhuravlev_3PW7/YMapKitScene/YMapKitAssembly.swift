//
//  YMapKitAssembly.swift
//  vazhuravlev_3PW7
//
//  Created by Валерий Журавлев on 18.03.2022.
//

import Foundation
import UIKit

// Assembles YMapKitScene
class YMapKitAssembly {
    func assemble() -> UIViewController {
        let view = YMapKitViewController()
        let interactor = YMapKitInteractor()
        let presenter = YMapKitPresenter()
        
        view.interactor = interactor
        interactor.presenter = presenter
        presenter.view = view
        
        return view
    }
}
