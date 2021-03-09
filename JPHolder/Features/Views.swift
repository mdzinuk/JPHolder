//
//  Views.swift
//  JPHolder
//
//  Created by Mohammad Arafat Hossain on 9/03/21.
//

import SwiftUI

struct ItemRow<T: Itemable>: View {
    let item: T
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: VerticalAlignment.firstTextBaseline, spacing: 2.0) {
                Text("\(item.counter))")
                    .font(.callout)
                    .foregroundColor(Color.primary)
                    .frame(width: 40, height: 40, alignment: .topLeading)
                Text(item.title)
                    .font(.title3)
                    .foregroundColor(Color.primary)
                    .lineLimit(2)
                    .frame(alignment: .leading)
            }
            Spacer(minLength: 8)
            Text(item.description)
                .font(.body)
                .foregroundColor(Color.gray)
        }
    }
}

struct Spinner: View {
    var body: some View {
        ProgressView("Loading …")
    }
}
