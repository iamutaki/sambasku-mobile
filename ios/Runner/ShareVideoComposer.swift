import AVFoundation
import Flutter
import UIKit

enum ShareVideoComposer {
  static func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "compose" else {
      result(FlutterMethodNotImplemented)
      return
    }
    guard
      let args = call.arguments as? [String: Any],
      let videoPath = args["videoPath"] as? String,
      let overlayPath = args["overlayPngPath"] as? String,
      let outputPath = args["outputPath"] as? String
    else {
      result(
        FlutterError(
          code: "bad_args",
          message: "argumen compose tidak lengkap",
          details: nil
        )
      )
      return
    }
    let maxSeconds = (args["maxSeconds"] as? NSNumber)?.doubleValue ?? 15
    compose(
      videoPath: videoPath,
      overlayPath: overlayPath,
      outputPath: outputPath,
      maxSeconds: maxSeconds,
      result: result
    )
  }

  private static func compose(
    videoPath: String,
    overlayPath: String,
    outputPath: String,
    maxSeconds: Double,
    result: @escaping FlutterResult
  ) {
    let videoURL = URL(fileURLWithPath: videoPath)
    let overlayURL = URL(fileURLWithPath: overlayPath)
    let outputURL = URL(fileURLWithPath: outputPath)

    let asset = AVURLAsset(url: videoURL)
    guard let videoTrack = asset.tracks(withMediaType: .video).first else {
      result(FlutterError(code: "no_video", message: "file tanpa trek video", details: nil))
      return
    }

    guard let overlayImage = UIImage(contentsOfFile: overlayURL.path)?.cgImage else {
      result(FlutterError(code: "no_overlay", message: "overlay PNG gagal dibaca", details: nil))
      return
    }

    let duration = min(asset.duration, CMTime(seconds: maxSeconds, preferredTimescale: 600))
    let timeRange = CMTimeRange(start: .zero, duration: duration)
    let natural = videoTrack.naturalSize.applying(videoTrack.preferredTransform)
    let renderSize = CGSize(width: abs(natural.width), height: abs(natural.height))

    let mix = AVMutableComposition()
    guard
      let compositionTrack = mix.addMutableTrack(
        withMediaType: .video,
        preferredTrackID: kCMPersistentTrackID_Invalid
      )
    else {
      result(FlutterError(code: "compose", message: "gagal buat composition", details: nil))
      return
    }
    do {
      try compositionTrack.insertTimeRange(timeRange, of: videoTrack, at: .zero)
    } catch {
      result(FlutterError(code: "compose", message: error.localizedDescription, details: nil))
      return
    }

    let instruction = AVMutableVideoCompositionInstruction()
    instruction.timeRange = timeRange
    let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionTrack)
    layerInstruction.setTransform(videoTrack.preferredTransform, at: .zero)
    instruction.layerInstructions = [layerInstruction]

    let videoComposition = AVMutableVideoComposition()
    videoComposition.instructions = [instruction]
    videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
    videoComposition.renderSize = renderSize

    let parent = CALayer()
    parent.frame = CGRect(origin: .zero, size: renderSize)
    let videoLayer = CALayer()
    videoLayer.frame = parent.frame
    let overlayLayer = CALayer()
    overlayLayer.contents = overlayImage
    overlayLayer.frame = parent.frame
    overlayLayer.contentsGravity = .resizeAspect
    overlayLayer.isGeometryFlipped = true
    parent.addSublayer(videoLayer)
    parent.addSublayer(overlayLayer)
    videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(
      postProcessingAsVideoLayer: videoLayer,
      in: parent
    )

    if FileManager.default.fileExists(atPath: outputURL.path) {
      try? FileManager.default.removeItem(at: outputURL)
    }

    guard
      let export = AVAssetExportSession(asset: mix, presetName: AVAssetExportPresetHighestQuality)
    else {
      result(FlutterError(code: "export", message: "gagal buat export session", details: nil))
      return
    }
    export.outputURL = outputURL
    export.outputFileType = .mp4
    export.timeRange = timeRange
    export.videoComposition = videoComposition
    export.exportAsynchronously {
      DispatchQueue.main.async {
        switch export.status {
        case .completed:
          result(outputURL.path)
        default:
          result(
            FlutterError(
              code: "export",
              message: export.error?.localizedDescription ?? "export gagal",
              details: nil
            )
          )
        }
      }
    }
  }
}
