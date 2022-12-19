//
//  HomeView.swift
//  UltimatePortfolio
//
//  Created by Justin Hold on 11/27/22.
//
import CoreData
import CoreSpotlight
import SwiftUI

struct HomeView: View {
	static let tag: String? = "Home"
	@StateObject var viewModel: ViewModel
	var projectRows: [GridItem] {
		[GridItem(.fixed(100))]
	}
	init(dataController: DataController) {
		let viewModel = ViewModel(dataController: dataController)
		_viewModel = StateObject(wrappedValue: viewModel)
	}
    var body: some View {
		NavigationStack {
			ScrollView {
				if let item = viewModel.selectedItem {
					NavigationLink(
						value: item,
						label: EmptyView.init
					)
					.id(item)
				}
				VStack(alignment: .leading) {
					ScrollView(.horizontal, showsIndicators: false) {
						LazyHGrid(rows: projectRows) {
							ForEach(viewModel.projects, content: ProjectSummaryView.init)
						}
						.padding([.horizontal, .top])
						.fixedSize(horizontal: false, vertical: true)
					}
					VStack(alignment: .leading) {
						ItemListView(title: "Up Next", items: viewModel.upNext)
						ItemListView(title: "More To Explore", items: viewModel.moreToExplore)
					}
					.padding(.horizontal)
				}
			}
			.background(Color.systemGroupedBackground.ignoresSafeArea())
			.navigationTitle("Home")
			.toolbar {
				Button("Add Data", action: viewModel.addSampleData)
			}
			.onContinueUserActivity(CSSearchableItemActionType, perform: loadSpotlightItem)
		}
    }
	func loadSpotlightItem(_ userActivity: NSUserActivity) {
		if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
			viewModel.selectItem(with: uniqueIdentifier)
		}
	}
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
		HomeView(dataController: .preview)
    }
}

// MARK: NAVIGATIONLINK CODE REPLACEMENT FOR LINE 25
// NavigationLink(
//	 destination: EditItemView(item: item),
//	 tag: item,
//	 selection: $viewModel.selectedItem,
//	 label: EmptyView.init
// )
// .id(item)

// MARK: BUTTON FOR TESTING ADDING DATA
// .toolbar {
//	 Button("Add Data") {
//	    dataController.deleteAll()
//	    try? dataController.createSampleData()
//	 }
// }
