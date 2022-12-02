//
//  SelectSomethingView.swift
//  ProjectManager
//
//  Created by Justin Hold on 12/1/22.
//

import SwiftUI

struct SelectSomethingView: View {
    var body: some View {
        Text("Select something from the menu to begin.")
			.italic()
			.foregroundColor(.secondary)
    }
}

struct SelectSomethingView_Previews: PreviewProvider {
    static var previews: some View {
        SelectSomethingView()
    }
}
