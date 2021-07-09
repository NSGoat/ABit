import XCTest
@testable import ABit

class ABitTests: XCTestCase {

    let url = URL(fileURLWithPath: Bundle.main.path(forResource: "Winstons - Amen, Brother", ofType: "aif")!)

    func test_fileLoading_success() throws {
        let config = AudioPlayerConfigurationManager()
        let sut = AudioFilePlayer(audioFileManager: config, cacheKey: "TEST")

        XCTAssertTrue(sut.state == .awaitingFile)

        let loadedFile = expectation(description: "loaded file")

        sut.loadAudioFile(url: url) { success in
            XCTAssertTrue(success)
            XCTAssertEqual(sut.state, .stopped)
            loadedFile.fulfill()
        }
        XCTAssertEqual(sut.state, .loading)

        wait(for: [loadedFile], timeout: 3)
    }

    func test_fileLoading_invalidPath() throws {
        let config = AudioPlayerConfigurationManager()
        let sut = AudioFilePlayer(audioFileManager: config, cacheKey: "TEST")

        let invalidUrl = URL(fileURLWithPath: "not/a/path")

        XCTAssertTrue(sut.state == .awaitingFile)

        let loadedFile = expectation(description: "loaded file")

        sut.loadAudioFile(url: invalidUrl) { success in
            XCTAssertFalse(success)
            XCTAssertEqual(sut.state, .awaitingFile)
            loadedFile.fulfill()
        }

        wait(for: [loadedFile], timeout: 3)
    }

    func testPerformance_waveformRendering_perform() throws {
        let config = AudioPlayerConfigurationManager()
        let sut = AudioFilePlayer(audioFileManager: config, cacheKey: "TEST")

        self.measure {
            for _ in 0..<50 {
                sut.loadAudioFile(url: url) { success in
                    XCTAssert(success)
                }
            }
        }
    }
}
