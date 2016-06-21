//
//  Utils.swift
//  ServerTemp
//
//  Created by BdevNameless on 21.06.16.
//  Copyright © 2016 Nikita Karaulov. All rights reserved.
//

import Foundation

class Utils {
    
    static func realtiveStringForHours(in_hours: Int) -> String {
        if in_hours >= 11&&in_hours<=20 {
            return "\(in_hours) Часов"
        }
        var result = ""
        switch in_hours%10 {
        case 0:
            result = "\(in_hours) Часов"
        case 1:
            result = "\(in_hours) Час"
            break
        case 2...4:
            result = "\(in_hours) Часа"
            break
        case 5...9:
            result = "\(in_hours) Часов"
            break
        default:
            break
        }
        return result
    }
    
}
