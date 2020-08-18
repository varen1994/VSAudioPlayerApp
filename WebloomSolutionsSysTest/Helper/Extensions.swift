//
//  Extensions.swift
//  WebloomSolutionsSysTest
//
//  Created by Varender Singh on 16/08/20.
//  Copyright © 2020 Varender. All rights reserved.
//

import Foundation
import UIKit


extension UITableViewCell {
    
    class func nibName()->String {
        return String(describing: self)
    }
    
    class func nib()->UINib {
        return UINib(nibName: self.nibName(), bundle: nil)
    }
    
}
