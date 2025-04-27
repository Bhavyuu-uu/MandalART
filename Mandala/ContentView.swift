//
//  ContentView.swift
//  Mandala
//
//  Created by ren on 27/04/25.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @StateObject private var viewModel = WallpaperViewModel()
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var showingSettings = false
    @State private var fullscreenWallpaper: Wallpaper? = nil
    @Namespace private var animation
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    FancyTitleView()
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            ForEach(viewModel.wallpapers) { wallpaper in
                                WallpaperLargeCard(
                                    wallpaper: wallpaper,
                                    viewModel: viewModel,
                                    onFullscreen: {
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                                            fullscreenWallpaper = wallpaper
                                        }
                                    },
                                    animation: animation,
                                    isFullscreen: fullscreenWallpaper?.id == wallpaper.id
                                )
                                .frame(maxWidth: .infinity)
                                .aspectRatio(9/16, contentMode: .fit)
                                .padding(.horizontal, 8)
                                .transition(.asymmetric(insertion: .opacity.combined(with: .scale), removal: .opacity))
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    HStack(spacing: 20) {
                        AnimatedButton(action: { showingImagePicker = true }, systemName: "photo")
                        AnimatedButton(action: { viewModel.generateWallpaper() }, systemName: "wand.and.stars")
                        AnimatedButton(action: { showingSettings = true }, systemName: "gear")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    .padding()
                }
                
                if let wallpaper = fullscreenWallpaper, let uiImage = UIImage(data: wallpaper.imageData) {
                    ZStack(alignment: .topTrailing) {
                        Color.black.opacity(0.98)
                            .ignoresSafeArea()
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black)
                            .matchedGeometryEffect(id: wallpaper.id, in: animation)
                        Button(action: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                                fullscreenWallpaper = nil
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(radius: 8)
                                .padding()
                        }
                        .transition(.scale)
                    }
                    .transition(.opacity)
                    .zIndex(2)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(viewModel: viewModel)
            }
        }
    }
}

struct WallpaperLargeCard: View {
    let wallpaper: Wallpaper
    @ObservedObject var viewModel: WallpaperViewModel
    var onFullscreen: () -> Void
    var animation: Namespace.ID
    var isFullscreen: Bool
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let uiImage = UIImage(data: wallpaper.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(radius: 10)
                    .matchedGeometryEffect(id: wallpaper.id, in: animation)
            }
            HStack(spacing: 16) {
                AnimatedButton(action: { viewModel.regenerateWallpaper(wallpaper) }, systemName: "arrow.clockwise")
                AnimatedButton(action: { viewModel.deleteWallpaper(wallpaper) }, systemName: "trash", color: .red)
                AnimatedButton(action: { onFullscreen() }, systemName: "arrow.up.left.and.arrow.down.right")
            }
            .padding(12)
        }
        .padding(.vertical, 4)
    }
}

struct AnimatedButton: View {
    var action: () -> Void
    var systemName: String
    var color: Color = .primary
    @State private var pressed = false
    var body: some View {
        Button(action: {
            withAnimation(.easeIn(duration: 0.12)) {
                pressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                withAnimation(.easeOut(duration: 0.12)) {
                    pressed = false
                }
                action()
            }
        }) {
            Image(systemName: systemName)
                .foregroundColor(color)
                .padding(8)
                .background(Color(.systemBackground).opacity(0.7))
                .clipShape(Circle())
                .scaleEffect(pressed ? 0.85 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.image = image as? UIImage
                    }
                }
            }
        }
    }
}

struct SettingsView: View {
    @ObservedObject var viewModel: WallpaperViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Resolution")) {
                    Picker("Resolution", selection: $viewModel.selectedResolution) {
                        Text("iPhone XS Max").tag(CGSize(width: 1242, height: 2688))
                        Text("iPhone 12 Pro").tag(CGSize(width: 1170, height: 2532))
                        Text("iPhone SE").tag(CGSize(width: 750, height: 1334))
                    }
                }
                
                Section(header: Text("Pattern")) {
                    Text("Mandala")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                }
                
                Section(header: Text("Palette")) {
                    Picker("Palette Type", selection: $viewModel.paletteType) {
                        Text("Vibrant").tag(PaletteType.vibrant)
                        Text("Pastel").tag(PaletteType.pastel)
                        Text("Custom (From Image)").tag(PaletteType.customImage)
                        Text("Custom (Manual)").tag(PaletteType.customManual)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if viewModel.paletteType == .customManual {
                        ForEach(0..<max(3, viewModel.customPalette.count), id: \ .self) { i in
                            ColorPicker("Color \(i+1)", selection: Binding(
                                get: {
                                    if i < viewModel.customPalette.count {
                                        return viewModel.customPalette[i]
                                    } else {
                                        return .white
                                    }
                                },
                                set: { newColor in
                                    if i < viewModel.customPalette.count {
                                        viewModel.customPalette[i] = newColor
                                    } else {
                                        viewModel.customPalette.append(newColor)
                                    }
                                }
                            ))
                        }
                        Button("Add Color") {
                            viewModel.customPalette.append(.white)
                        }
                    }
                    if viewModel.paletteType == .customImage {
                        Text("Palette will be extracted from your selected image.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Section {
                    Button("Clear All Wallpapers") {
                        viewModel.clearAllWallpapers()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

#Preview {
    ContentView()
}
