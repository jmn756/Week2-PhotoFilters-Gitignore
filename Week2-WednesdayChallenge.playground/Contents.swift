//: Playground - noun: a place where people can play

import UIKit

//Code Challenge: Write a function that computes the list of the first 100 Fibonacci numbers.
//Playground will only allow 92 before crashing


func fiboNums() ->[Int] {
  var fibo = [Int]()
  var first = 0
  var second = 1
  var sum: Int
  fibo.append(first)
  fibo.append(second)
  for (var i = 2; i <= 92; i++) {
     sum = first + second
     fibo.append(sum)
     first = second
     second = sum
  }
  return fibo
}

var ans = [Int]()
ans = fiboNums()

