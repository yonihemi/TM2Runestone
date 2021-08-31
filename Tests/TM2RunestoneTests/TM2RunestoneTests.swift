import XCTest
@testable import TM2Runestone

final class TM2RunestoneTests: XCTestCase {
	private func loadDracula() throws -> TMTheme {
		let themeURL = Bundle.module.url(forResource: "Dracula", withExtension: "tmTheme")!
		let themeData = try Data(contentsOf: themeURL)
		let decoder = PropertyListDecoder()
		let theme = try decoder.decode(TMTheme.self, from: themeData)
		return theme
	}
	
	func testParseTMTheme() throws {
		let theme = try loadDracula()
		
		XCTAssertEqual(theme.name, "Dracula")
		XCTAssertEqual(theme.scopeStyles.count, 74)
	}
	
	func testConvert() throws {
		let theme = try loadDracula()
		let runestoneTheme = RunestoneTheme(tmTheme: theme, appearance: .dark)
		
		XCTAssertEqual(theme.globalSettings.foreground, runestoneTheme.editor.text)
		XCTAssertEqual(theme.globalSettings.background, runestoneTheme.editor.background)
		XCTAssertEqual(runestoneTheme.editor.pageGuide.hairline, "#f8f8f2")
		XCTAssertEqual(runestoneTheme.scopes.count, 72)
		XCTAssertEqual(runestoneTheme.scopes.first(where: { $0.name == "number" })?.color, "#bd93f9")
		XCTAssertEqual(runestoneTheme.scopes.first(where: { $0.name == "storage.type.namespace.cs" })?.color, "#ff79c6")
	}
}
