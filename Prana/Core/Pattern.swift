//
//  PatternSequence.swift
//  Prana
//
//  Created by Luccas on 3/19/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation

class Pattern {
    
    //inhalationTime = 3;
    //retentionTime = 4;
    //exhalationTime = 5;
    //timeBetweenBreaths = 1;
    
    //the values herein define the # of columns of flowers now!!!! Each column is 0.50 seconds. That's the best reliable granularity.
    
    static let patternSequence:[[[Any]]] = [
        
        //Dynamic slow breathing pattern
        [
            [1,0,1,0.5], //24 bpm
            [1,0,1.5,0.5], //20 bpm
            
            [1,0,1.5,1], //17.14 bpm
            [1.5,0,1.5,1], //15 bpm
            
            [1.5,0,1.5,1.5], //13.3 bpm
            [1.5,0,2,1.5], //12 bpm
            
            [1.5,0,2,2], //10.9 bpm
            [2,0,2,2], //10 bpm
            
            [2,0,2,2.5], //9.2 bpm
            [2,0,2.5,2.5], //8.6 bpm
            
            [2,0,2.5,3], //8 bpm
            [2.5,0,2.5,3], //7.5 bpm
            
            [3,0,2.5,3], //7.1 bpm
            [3,0,3,3], //6.7 bpm
            
            [3,0,3,3.5], //6.3 bpm
            [3.5,0,3,3.5], //6 bpm
            
            [3.5,0,3.5,3.5], //5.7 bpm
            [4,0,3.5,3.5], //5.5 bpm
            
            [4,0,3.5,4], //5.2 bpm
            [4,0,4,4], //5 bpm
            
            [4.5,0,4,4], //4.8 bpm
            [4.5,0,4.5,4], //4.6 bpm
            
            [4.5,0,4.5,4.5], //4.4 bpm
            [5,0,4.5,4.5], //4.3 bpm
            
            [5,0,5,4.5], //4.1 bpm
            [5.5,0,5,4.5], //4 bpm
            
            [5.5,0,5,5], //3.9 bpm
            [5.5,0,5.5,5], //3.8 bpm
            
            [6,0,5.5,5], //3.6 bpm
            [6,0,6,5], //3.5 bpm
            
            [6,0,6,5.5], //3.4 bpm
            [6.5,0,6,5.5], //3.3 bpm
            
            [6.5,0,6.5,5.5], //3.2 bpm
            [7,0,7,5.5], //3.1 bpm
            
            [7,0,7,6], //3 bpm
        ],
        
        //Meditation 1 breathing pattern
        [
            [1,0,1,1,"MEDITATION PATTERN 1"],
            [2,0,2,1.5],
            [3,0,3,1.5],
            [4,0,4,2],
            [5,0,5,2],
        ],
        
        //Meditation 2 breathing pattern
        [
            [2,0,1,1,"MEDITATION PATTERN 2"],
            [2,0,2,1.5],
            [2,0,3,1.5],
            [2,0,4,2],
            [2,0,5,2],
        ],
        
        //Focus breathing patterns
        [
            [1.5,0,1.5,1,"FOCUS PATTERN 15 BPM"], //15 bpm
        ],
        [
            [1.5,0,1.5,2,"FOCUS PATTERN 12 BPM"], //12 bpm
        ],
        [
            [2,0,2,2,"FOCUS PATTERN 10 BPM"], //10 bpm
        ],
        [
            [2.5,0,2.5,2.5,"FOCUS PATTERN 8 BPM"], //8 bpm
        ],
        [
            [3.5,0,3.5,3,"FOCUS PATTERN 6 BPM"], //6 bpm
        ],
        
        //Relax breathing patterns
        [
            [1,0,2,1,"RELAX PATTERN 15 BPM"], //15 bpm
        ],
        [
            [1,0,2,2,"RELAX PATTERN 12 BPM"], //12 bpm
        ],
        [
            [1.5,0,3,1.5,"RELAX PATTERN 10 BPM"], //10 bpm
        ],
        [
            [1.5,0,3,3,"RELAX PATTERN 8 BPM"], //8 bpm
        ],
        [
            [2.5,0,5,2.5,"RELAX PATTERN 6 BPM"], //6 bpm
        ],
        
        //Sleep breathing patterns
        [
            [2,3,4,2,"SLEEP PATTERN 2-3-4"], //15 bpm
        ],
        [
            [3,5,6,2.5,"SLEEP PATTERN 3-5-6"], //12 bpm
        ],
        [
            [4,7,8,3,"SLEEP PATTERN 4-7-8"], //10 bpm
        ],
    ];
    
}
