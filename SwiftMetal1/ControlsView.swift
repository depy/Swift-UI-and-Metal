import SwiftUI

struct ControlsView: View {
    @EnvironmentObject var renderData: RenderData
    @State var red: Double = 0.0
    @State var green: Double = 0.0
    @State var blue: Double = 0.0
    
    var body: some View {
        VStack {
            HStack {
                Text("Red")
                Slider(
                    value: Binding(get: {
                        self.red
                    }, set: {(newValue) in
                        self.red = newValue
                        renderData.bgColor = [self.red, self.green, self.blue]
                    }),
                    in: 0...1
                )
            }
            HStack {
                Text("Green")
                Slider(
                    value: Binding(get: {
                        self.green
                    }, set: {(newValue) in
                        self.green = newValue
                        renderData.bgColor = [self.red, self.green, self.blue]
                    }),
                    in: 0...1
                )
            }
            HStack {
                Text("Blue ")
                Slider(
                    value: Binding(get: {
                        self.blue
                    }, set: {(newValue) in
                        self.blue = newValue
                        renderData.bgColor = [self.red, self.green, self.blue]
                    }),
                    in: 0...1
                )
            }
        }
    }
}

struct ControlsView_Previews: PreviewProvider {
    static var previews: some View {
        ControlsView()
    }
}
