import XCTest
import SwiftSyntax
import SwiftSyntaxBuilder

final class ExprListTests: XCTestCase {
  func testExprList() {
    let testCases: [UInt: (ExprList, String)] = [
      #line: (ExprList([IntegerLiteralExpr(1), BinaryOperatorExpr("+"), FloatLiteralExpr(2.34)]), "1 + 2.34"),
      #line: ([IntegerLiteralExpr(1), BinaryOperatorExpr("+"), FloatLiteralExpr(2.34)], "1 + 2.34")
    ]

    for (line, testCase) in testCases {
      let (builder, expected) = testCase
      AssertBuildResult(builder, expected, line: line)
    }
  }
}
