//
//  ConditionalFlowComposite.swift
//  CatsDogs
//
//  Created by Danil Lahtin on 08.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//


final class ConditionalFlowComposite: Flow {
    private let primary: Flow
    private let secondary: Flow
    private let condition: () -> Bool
    
    init(primary: Flow, secondary: Flow, condition: @escaping () -> Bool) {
        self.primary = primary
        self.secondary = secondary
        self.condition = condition
    }
    
    func start() {
        let flow = condition() ? primary : secondary
        
        flow.start()
    }
}
