//
//  MapKitAssembly.swift
//  vazhuravlev_3PW7
//
//  Created by Валерий Журавлев on 18.03.2022.
//

import Foundation
import UIKit

// Assembles MapKitScene
class MapKitAssembly {
    func assemble() -> UIViewController {
        let view = MapKitViewController()
        let interactor = MapKitInteractor()
        let presenter = MapKitPresenter()
        
        view.interactor = interactor
        interactor.presenter = presenter
        presenter.view = view
        
        return view
    }
}
