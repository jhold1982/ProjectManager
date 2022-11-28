//
//  HomeView.swift
//  UltimatePortfolio
//
//  Created by Justin Hold on 11/27/22.
//

import SwiftUI

struct HomeView: View {
	
	@EnvironmentObject var dataController: DataController
	
    var body: some View {
		
		NavigationView {
			VStack {
				Button("Add data") {
					dataController.deleteAll()
					try? dataController.createSampleData()
				}
				.navigationTitle("Home")
			}
		}
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
