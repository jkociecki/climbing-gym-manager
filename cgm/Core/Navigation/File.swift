            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showGrid = true
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    isGridAnimating = true
                }
            }