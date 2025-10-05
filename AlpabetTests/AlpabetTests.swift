import XCTest
import UIKit
import SnapshotTesting
@testable import Tracker

final class AlpabetTests: XCTestCase {

    override func setUpWithError() throws {
        // Включите запись эталонных изображений один раз, затем верните в false.
        isRecording = false


        UserDefaults.standard.removeObject(forKey: "Trackers.CurrentFilter")

        try cleanPersistentData()
    }

    override func tearDownWithError() throws {
        // Ничего
    }

    // MARK: - Empty state snapshots

    @MainActor
    func testTrackersViewController_Empty_Light() {
        let sut = TrackersViewController()
        sut.overrideUserInterfaceStyle = .light
        sut.loadViewIfNeeded()
        sut.view.layoutIfNeeded()

      
        waitForUIUpdate()

        assertSnapshot(
            matching: sut,
            as: .image(on: .iPhoneX),
            named: "Empty_Light"
        )
    }

    @MainActor
    func testTrackersViewController_Empty_Dark() {
        let sut = TrackersViewController()
        sut.overrideUserInterfaceStyle = .dark
        sut.loadViewIfNeeded()
        sut.view.layoutIfNeeded()

        waitForUIUpdate()

        assertSnapshot(
            matching: sut,
            as: .image(on: .iPhoneX),
            named: "Empty_Dark"
        )
    }

    // MARK: - Populated state snapshots

    @MainActor
    func testTrackersViewController_Populated_Light() throws {
        try populateSampleData()

        let sut = TrackersViewController()
        sut.overrideUserInterfaceStyle = .light
        sut.loadViewIfNeeded()
        sut.view.layoutIfNeeded()

        // Даем VM применить onChange и обновить UI
        waitForUIUpdate()

        assertSnapshot(
            matching: sut,
            as: .image(on: .iPhoneX),
            named: "Populated_Light"
        )
    }

    @MainActor
    func testTrackersViewController_Populated_Dark() throws {
        try populateSampleData()

        let sut = TrackersViewController()
        sut.overrideUserInterfaceStyle = .dark
        sut.loadViewIfNeeded()
        sut.view.layoutIfNeeded()

     
        waitForUIUpdate()

        assertSnapshot(
            matching: sut,
            as: .image(on: .iPhoneX),
            named: "Populated_Dark"
        )
    }

    // MARK: - Helpers

    private func cleanPersistentData() throws {
        // Удаляем записи выполнения
        let recordStore = TrackerRecordStore()
        if let records = try? recordStore.fetchRecords() {
            for r in records {
                try? recordStore.removeRecord(r)
            }
        }

 
        let trackerStore = TrackerStore()
        if let trackers = try? trackerStore.fetchTrackers() {
            for t in trackers {
                try? trackerStore.deleteTracker(t)
            }
        }

        let categoryStore = TrackerCategoryStore()
        if let titles = try? categoryStore.fetchAllCategories() {
            for title in titles {
                try? categoryStore.deleteCategory(title: title)
            }
        }
    }

    private func populateSampleData() throws {
        let trackerStore = TrackerStore()

        let t1 = Tracker(
            id: UUID(),
            title: "Drink Water",
            emoji: "💧",
            color: .red,
            schedule: nil // без расписания — виден в любой день
        )

        try trackerStore.addTracker(t1, to: "Health")
     //   try trackerStore.addTracker(t2, to: "Health")
    }

  
    private func waitForUIUpdate(file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "UI updated")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
}
