//
//  buldersChart.swift
//  temp
//
//  Created by Malwina Juchiewicz on 03/01/2025.
//

import SwiftUI

struct BoulderGradeChart: View {
    @Environment(\.colorScheme) var colorScheme
    let gradeData: [(grade: String, count: Int)]
    @State private var selectedGrade: String?
    @State private var isAnimating: Bool = false
    
    static let sampleData: [(grade: String, count: Int)] = [
        ("4A", 12), ("4B", 15), ("4C", 18),
        ("5A", 25), ("5B", 22), ("5C", 20),
        ("6A", 16), ("6B", 14), ("6C", 10),
        ("7A", 8), ("7B", 5), ("7C", 3)
    ]
    
    private var maxCount: Int {
        gradeData.map { $0.count }.max() ?? 0
    }
    
    private var totalBoulders: Int {
        gradeData.map { $0.count }.reduce(0, +)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            summarySection
            chartSection
        }
        .padding(16)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimating = true
            }
        }
    }
    
    private var summarySection: some View {
        HStack(spacing: 32) {
            VStack(alignment: .center, spacing: 4) {
                Text("Total Boulders")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                Text("\(totalBoulders)")
                    .font(.system(size: 20, weight: .bold))
            }
            
            Divider()
                .frame(height: 40)
                .padding(.horizontal)
            
            VStack(alignment: .center, spacing: 4) {
                Text("Most Common")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                Text(gradeData.max(by: { $0.count < $1.count })?.grade ?? "-")
                    .font(.system(size: 20, weight: .bold))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray5))
        )
    }


    
    private var chartSection: some View {
        VStack(spacing: 12) {
            ForEach(gradeData, id: \.grade) { item in
                HStack(spacing: 12) {
                    // Grade label
                    Text(item.grade)
                        .font(.system(size: 14, weight: .medium))
                        .frame(width: 40, alignment: .leading)
                        .foregroundColor(selectedGrade == item.grade ? .primary : .secondary)
                    
                    // Bar
                    GeometryReader { geometry in
                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(
                                        colors: selectedGrade == item.grade
                                            ? [Color.czerwony, Color.fioletowy]
                                            : [Color.czerwony.opacity(0.8), Color.fioletowy.opacity(0.8)]
                                    ),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: isAnimating
                                    ? CGFloat(item.count) / CGFloat(maxCount) * geometry.size.width
                                    : 0
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(
                                        Color.white.opacity(0.2),
                                        lineWidth: 1
                                    )
                            )
                    }
                    .frame(height: 20)
                    
                    // Count label
                    Text("\(item.count)")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .frame(width: 30, alignment: .trailing)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.spring()) {
                        selectedGrade = selectedGrade == item.grade ? nil : item.grade
                    }
                }
            }
        }
    }
    
    
}



struct BoulderGradeChart_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BoulderGradeChart(gradeData: BoulderGradeChart.sampleData)
                .preferredColorScheme(.light)
            
            BoulderGradeChart(gradeData: BoulderGradeChart.sampleData)
                .preferredColorScheme(.dark)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
