//
//  Body.swift
//  Prana
//
//  Created by Guru on 6/18/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation
import UIKit

protocol BodyDelegate {
    func bodyDidCalculateDistance(distance: Double)
}

class Body {
    var dataArray: [Double] = []
    var rDistance: [Double] = []
    
    var startAngle:Double = 0;
    var finalAngle:Double = 0;
    
    var linearDistance:Double = 0;
    
    var objLive: Live?
    
    var delegate: BodyDelegate?
    
    init(live: Live) {
        objLive = live
        objLive?.addDelegate(self)
        setUpDistanceTable();
    }
    
    func setUpDistanceTable() {
    
    rDistance = [0,20.2,33.85,47.67,62.53,77.36,93.23,106.83,121.97,136.18,151.92,163.99,179.38,195.49,209.14,222.71,237.29,250.33,265.26,277.79,292.1,306.07,320.85,335.89,351.70,366.86,380.41,396.09,410.70,427.14,441.39,456.91,473.14,485.24,500.98,514.97,530.53,545,559,574.36,589.56,605.43,619.72,633.06,648.38,662.80,674.74,687.57,709.95,725.47,739.79,757.80,771.75,787.08,799.76,818.92,832.1,847.49,860.54,877.76,890.44,908.41,921.58,940.94,954.23,965.97,983.04,997.16,1013.64,1029.64,1046.13,1060.86,1075.49,1092.89,1107.88,1126.42,1141.83,1153.85,1169.14,1185.84,1201.99,1217.41,1233.25,1248.78,1266.36,1282.14,1296.39,1311.96,1328.29,1343.40,1358.71,1375.47,1391.05,1406.63,1425.57,1439.20,1456.18,1474.01,1487.46,1502.82,1521.13,1535.67,1549.81,1566.84,1583.29,1599.75,1617.32,1633.44,1650.74,1665.13,1678.54,1697.01,1712.74,1728.28,1745.69,1760.49,1778.62,1796.41,1811.21,1831.76,1848.65,1863.87,1878.92,1895.78,1911.09,1930.85,1943.94,1961.47,1976.95,1995.14,2012.05,2029.50,2047.56,2064.58,2081,2098.16,2112.97,2129.94,2145.72,2165.13,2181.18,2203.78,2217.51,2237.17,2252.22,2271.69,2287.42,2301.64,2320.40,2340.40,2353.74,2373.24,2388.28,2405.88,2425.12,2442.02,2457.59,2476.43,2490.71,2510.36,2529.96,2544.28,2562.72,2579.15,2596.49,2613.14,2631.55,2651.19,2670.45,2687.86,2706.45,2724.43,2739.45,2759.79,2777.45,2795.11,2812.68,2830.19,2847.86,2870.22,2888.51,2907.6,2925.7,2944.19,2960.34,2978.7,2998.27,3014.23,3033.86,3051.21,3070.66,3088.49,3104.74,3125.08,3140.66,3160.59,3181.27,3200.2,3218.40,3240.62,3255.36,3272.09,3291,3310.61,3332.24,3353.04,3371.48,3388.52,3407.94,3428.96,3446,3463.97,3491.13,3503.98,3524.85,3538.72,3563.15,3579.92,3597.13,3619.63,3635.84,3649.77,3673.89,3692.61,3710.73,3733.66,3753.58,3773.64,3794.24,3814.24,3830.15,3848.61,3870.57,3888.97,3908.63,3930.29,3949.29,3973.02,3989.80,4012.91,4032.28,4050.72,4071.84,4093.06,4113.73,4135.23,4156.01,4175.87,4193.80,4212.9,4234.82,4256.01,4275.71,4295.66,4316.31,4337.44,4361.07,4390.36,4404.35,4414.83,4447.83,4464.30,4480.49,4502.68,4524.34,4552.27,4563.06,4585.53,4609.84,4630.44,4653.41,4686.37,4699.69,4718.99,4742.47,4762.35,4785.04,4810.59,4831,4851.80,4872.53,4895.03,4921,4943.13,4961.22,4977.67,4997.86,5021.77,5040.76,5063.94,5082.72,5107.74,5121.55]
    
    }
    
    func start() {
        guard dataArray.count == 7 else { return }
        startAngle = dataArray[5]
    }
    
    func stop() {
        guard dataArray.count == 7 else { return }
        finalAngle = dataArray[5] - startAngle;
        
        linearDistance = -1234;
        for i in 0...rDistance.count {
            if (finalAngle <= rDistance[i]) {
                if (i > 0) {
                    
                    linearDistance = 1.5 + (Double(i)/2.0) + 0.5*(1-((rDistance[i] - finalAngle)/(rDistance[i] - rDistance[i-1])));
                    break;
                }
            }
        }
        
        linearDistance = linearDistance / 2.54;
        
        delegate?.bodyDidCalculateDistance(distance: linearDistance)
    }
    
    func roundNumber(num:Double, dec:Double) -> Double {
        return round(num*dec)/dec
    }
    
}

extension Body: LiveDelegate {
    func liveMainLoop(timeElapsed: Double, sensorData: [Double]) {
        DispatchQueue.main.async {
            self.dataArray = sensorData
        }
    }
}
