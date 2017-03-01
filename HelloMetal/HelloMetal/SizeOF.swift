//
//  SizeOF.swift
//  HelloMetal
//
//  Created by derrick on 2017. 3. 2..
//  Copyright © 2017년 Superbderrick. All rights reserved.
//

import Foundation



func sizeof <T> (_ : T.Type) -> Int
{
	return (MemoryLayout<T>.size)
}

func sizeof <T> (_ : T) -> Int
{
	return (MemoryLayout<T>.size)
}

func sizeof <T> (_ value : [T]) -> Int
{
	return (MemoryLayout<T>.size * value.count)
}
