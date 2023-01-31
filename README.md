# VisionFrameworkSamples

## 概要

以下に機械学習における [オンデバイスAPI](https://developer.apple.com/jp/machine-learning/api/) として公開されている Vision フレームワークの処理内容やサンプルをまとめました。

多くの処理については公式のサンプルが公開されていますが、以下の処理についてはサンプルがなかったため本リポジトリで公開しています。

- 輪郭検出
- 人体検出
- 体の姿勢
- 動物認識
- 水平検出
- オプティカルフロー
- 書類検出

以下表の処理内容を確認したい場合は、サンプル番号の項目のリンク先にあるプロジェクトをビルドすることで実行することができます。
（番号は便宜上つけたものです、どのようなサンプルかについては表の下に記載している「Vision フレームワークサンプル一覧」の内容を参照ください）

## [Vision フレームワーク オンデバイスAPI](https://developer.apple.com/jp/machine-learning/api/)

Vision フレームワークは利用方法がどれもほぼ同じで、リクエスト時のパラメータと出力されるオブジェクトに注目すれば良い

| <div style="width:190px">処理内容</div> | <div style="width:90px">サンプル番号</div> | リクエスト | 出力オブジェクト |
| ---- | ---- | ----- | ----- |
| 画像識別 | [3](https://developer.apple.com/documentation/vision/classifying_images_for_categorization_and_search) | [VNClassifyImageRequest](https://developer.apple.com/documentation/vision/vnclassifyimagerequest) | [[VNClassificationObservation]](https://developer.apple.com/documentation/vision/vnclassificationobservation) |
| 画像の顕著性認識 | [6](https://developer.apple.com/documentation/vision/highlighting_areas_of_interest_in_an_image_using_saliency) | [VNGenerateAttentionBasedSaliencyImageRequest](https://developer.apple.com/documentation/vision/vngenerateattentionbasedsaliencyimagerequest)<br>[VNGenerateObjectnessBasedSaliencyImageRequest](https://developer.apple.com/documentation/vision/vngenerateobjectnessbasedsaliencyimagerequest) | [[VNSaliencyImageObservation]](https://developer.apple.com/documentation/vision/vnsaliencyimageobservation) |
| 画像の位置合わせ | [15](https://developer.apple.com/documentation/vision/aligning_similar_images), [19](https://developer.apple.com/documentation/vision/training_a_create_ml_model_to_classify_flowers)| [VNTranslationalImageRegistrationRequest](https://developer.apple.com/documentation/vision/vntranslationalimageregistrationrequest)<br>[VNHomographicImageRegistrationRequest](https://developer.apple.com/documentation/vision/vnhomographicimageregistrationrequest) | [[VNImageTranslationAlignmentObservation]](https://developer.apple.com/documentation/vision/vnimagetranslationalignmentobservation)<br>[[VNImageHomographicAlignmentObservation]](https://developer.apple.com/documentation/vision/vnimagehomographicalignmentobservation) |
| 画像の類似性判定 | [4](https://developer.apple.com/documentation/vision/analyzing_image_similarity_with_feature_print) | [VNGenerateImageFeaturePrintRequest](https://developer.apple.com/documentation/vision/vngenerateimagefeatureprintrequest) | [[VNFeaturePrintObservation]](https://developer.apple.com/documentation/vision/vnfeatureprintobservation) |
| オブジェクトの検出 | [2](https://developer.apple.com/documentation/vision/detecting_objects_in_still_images) | (複数のリクエスト) | (複数のオブジェクト) |
| オブジェクトのトラッキング | [8](https://developer.apple.com/documentation/vision/tracking_multiple_objects_or_rectangles_in_video) | (複数のリクエスト) | (複数のオブジェクト) |
| 軌道検出 | [11](https://developer.apple.com/documentation/vision/detecting_moving_objects_in_a_video) | [VNDetectTrajectoriesRequest](https://developer.apple.com/documentation/vision/vndetecttrajectoriesrequest) | [[VNTrajectoryObservation]](https://developer.apple.com/documentation/vision/vntrajectoryobservation) |
| 輪郭検出 | - | [VNDetectContoursRequest](https://developer.apple.com/documentation/vision/vndetectcontoursrequest) | [[VNContoursObservation]](https://developer.apple.com/documentation/vision/vncontoursobservation) |
| テキスト検出 | [2](https://developer.apple.com/documentation/vision/detecting_objects_in_still_images)| [VNDetectTextRectanglesRequest](https://developer.apple.com/documentation/vision/vndetecttextrectanglesrequest) | [[VNTextObservation]](https://developer.apple.com/documentation/vision/vntextobservation) |
| テキスト認識 | [12](https://developer.apple.com/documentation/vision/structuring_recognized_text_on_a_document), [13](https://developer.apple.com/documentation/vision/reading_phone_numbers_in_real_time), [14](https://developer.apple.com/documentation/vision/locating_and_displaying_recognized_text)| [VNRecognizeTextRequest](https://developer.apple.com/documentation/vision/vnrecognizetextrequest) | [[VNRecognizedTextObservation]](https://developer.apple.com/documentation/vision/vnrecognizedtextobservation) |
| 顔検出 | [2](https://developer.apple.com/documentation/vision/detecting_objects_in_still_images), [5](https://developer.apple.com/documentation/vision/applying_matte_effects_to_people_in_images_and_video), [7](https://developer.apple.com/documentation/vision/tracking_the_user_s_face_in_real_time) | [VNDetectFaceRectanglesRequest](https://developer.apple.com/documentation/vision/vndetectfacerectanglesrequest) | [[VNFaceObservation]](https://developer.apple.com/documentation/vision/vnfaceobservation) |
| フェイストラッキング | [7](https://developer.apple.com/documentation/vision/tracking_the_user_s_face_in_real_time)| (複数のリクエスト) | (複数のオブジェクト) |
| 顔のランドマーク | [2](https://developer.apple.com/documentation/vision/detecting_objects_in_still_images), [7](https://developer.apple.com/documentation/vision/tracking_the_user_s_face_in_real_time)| [VNDetectFaceLandmarksRequest](https://developer.apple.com/documentation/vision/vndetectfacelandmarksrequest) | [[VNFaceObservation]](https://developer.apple.com/documentation/vision/vnfaceobservation) |
| 顔のキャプチャクオリティ | [9](https://developer.apple.com/documentation/vision/selecting_a_selfie_based_on_capture_quality) | [VNDetectFaceCaptureQualityRequest](https://developer.apple.com/documentation/vision/vndetectfacecapturequalityrequest) | [[VNFaceObservation]](https://developer.apple.com/documentation/vision/vnfaceobservation) |
| 人体検出 | - | [VNDetectHumanRectanglesRequest](https://developer.apple.com/documentation/vision/vndetecthumanrectanglesrequest) | [[VNHumanObservation]](https://developer.apple.com/documentation/vision/vnhumanobservation) |
| 体の姿勢 | - | [VNDetectHumanBodyPoseRequest](https://developer.apple.com/documentation/vision/vndetecthumanbodyposerequest) | [[VNHumanBodyPoseObservation]](https://developer.apple.com/documentation/vision/vnhumanbodyposeobservation) |
| 手の形 | [10](https://developer.apple.com/documentation/vision/detecting_hand_poses_with_vision) | [VNDetectHumanHandPoseRequest](https://developer.apple.com/documentation/vision/vndetecthumanhandposerequest)| [[VNHumanHandPoseObservation]](https://developer.apple.com/documentation/vision/vnhumanhandposeobservation) |
| 動物認識 | - | [VNRecognizeAnimalsRequest](https://developer.apple.com/documentation/vision/vnrecognizeanimalsrequest) | [[VNRecognizedObjectObservation]](https://developer.apple.com/documentation/vision/vnrecognizedobjectobservation) |
| バーコード検出 | [2](https://developer.apple.com/documentation/vision/detecting_objects_in_still_images), [19](https://developer.apple.com/documentation/vision/training_a_create_ml_model_to_classify_flowers) | [VNDetectBarcodesRequest](https://developer.apple.com/documentation/vision/vndetectbarcodesrequest) | [[VNBarcodeObservation]](https://developer.apple.com/documentation/vision/vnbarcodeobservation) |
| 矩形検出 | [2](https://developer.apple.com/documentation/vision/detecting_objects_in_still_images), [8](https://developer.apple.com/documentation/vision/tracking_multiple_objects_or_rectangles_in_video) | [VNDetectRectanglesRequest](https://developer.apple.com/documentation/vision/vndetectrectanglesrequest) | [[VNRectangleObservation]](https://developer.apple.com/documentation/vision/vnrectangleobservation) |
| 水平検出 | - | [VNDetectHorizonRequest](https://developer.apple.com/documentation/vision/vndetecthorizonrequest) | [[VNHorizonObservation]](https://developer.apple.com/documentation/vision/vnhorizonobservation) |
| オプティカルフロー | - | [VNGenerateOpticalFlowRequest](https://developer.apple.com/documentation/vision/vngenerateopticalflowrequest) | [[VNPixelBufferObservation]](https://developer.apple.com/documentation/vision/vnpixelbufferobservation) |
| 人物セグメンテーション | [5](https://developer.apple.com/documentation/vision/applying_matte_effects_to_people_in_images_and_video) | [VNGeneratePersonSegmentationRequest](https://developer.apple.com/documentation/vision/vngeneratepersonsegmentationrequest) | [[VNPixelBufferObservation]](https://developer.apple.com/documentation/vision/vnpixelbufferobservation)  |
| 書類検出 | - | [VNDetectDocumentSegmentationRequest](https://developer.apple.com/documentation/vision/vndetectdocumentsegmentationrequest) | [[VNRectangleObservation]](https://developer.apple.com/documentation/vision/vnrectangleobservation) |


## Vision フレームワーク公式サンプル一覧

### エッセンシャル

- [1. スポーツ分析用の機能豊富なアプリの構築](https://developer.apple.com/documentation/vision/building_a_feature-rich_app_for_sports_analysis)
  - コンピューター ビジョンと機械学習を使用して、人間の活動をリアルタイムで検出して分類します。

### 静止画分析

- [2. 静止画像内のオブジェクトの検出](https://developer.apple.com/documentation/vision/detecting_objects_in_still_images)
  - Vision フレームワークを使用して、画像内の四角形、顔、バーコード、およびテキストを見つけて区別します。
  - 利用リクエスト
    - VNDetectRectanglesRequest
    - VNDetectFaceRectanglesRequest
    - VNDetectFaceLandmarksRequest
    - VNDetectTextRectanglesRequest
    - VNDetectBarcodesRequest

- [3. 分類と検索のための画像の分類](https://developer.apple.com/documentation/vision/classifying_images_for_categorization_and_search)
  - Vision 分類リクエストを使用して画像を分析し、ラベルを付けます。
  - 利用リクエスト
    - VNClassifyImageRequest

- [4. 特徴点を使用した画像の類似性の分析](https://developer.apple.com/documentation/vision/analyzing_image_similarity_with_feature_print)
  - 特徴点を生成して、画像間の距離を計算します。
  - 利用リクエスト
    - VNGenerateImageFeaturePrintRequest

### 画像シーケンス分析

- [5. 画像や動画の人物にマット効果を適用する](https://developer.apple.com/documentation/vision/applying_matte_effects_to_people_in_images_and_video)
  - セマンティックな人物セグメンテーションを使用して、人物の画像マスクを自動的に生成します。
  - 利用リクエスト
    - VNDetectFaceRectanglesRequest
    - VNGeneratePersonSegmentationRequest

### 顕著性分析

- [6. 顕著性を使用した画像内の関心領域の強調表示](https://developer.apple.com/documentation/vision/highlighting_areas_of_interest_in_an_image_using_saliency)
  - 人が画像のどこを見る可能性が高いかを数値化して視覚化します。
  - 利用リクエスト
    - VNGenerateAttentionBasedSaliencyImageRequest
    - VNGenerateObjectnessBasedSaliencyImageRequest

### オブジェクト追跡

- [7. ユーザーの顔をリアルタイムで追跡する](https://developer.apple.com/documentation/vision/tracking_the_user_s_face_in_real_time)
  - セルフィー カム フィードからリアルタイムで顔を検出して追跡します。
  - 利用リクエスト
    - VNDetectFaceRectanglesRequest
    - VNTrackObjectRequest
    - VNDetectFaceLandmarksRequest

- [8. ビデオ内の複数のオブジェクトまたは長方形の追跡](https://developer.apple.com/documentation/vision/tracking_multiple_objects_or_rectangles_in_video)
  - Vision アルゴリズムを適用して、ビデオ全体でオブジェクトまたは四角形を追跡します。
  - 利用リクエスト
    - VNDetectRectanglesRequest
    - (VNTrackingRequest)
    - VNTrackObjectRequest
    - VNTrackRectangleRequest

### 顔と体の検出

- [9. キャプチャ品質に基づいてセルフィーを選択する](https://developer.apple.com/documentation/vision/selecting_a_selfie_based_on_capture_quality)
  - Vision を使用して、一連の画像で顔のキャプチャ品質を比較します。
  - 利用リクエスト
    - VNDetectFaceCaptureQualityRequest

### 体と手の姿勢検出

- [10. Vision による手のポーズの検出](https://developer.apple.com/documentation/vision/detecting_hand_poses_with_vision)
  - 手のポーズを検出する Vision の機能を使用して、仮想描画アプリを作成します。
  - [参考ビデオ](https://developer.apple.com/videos/play/wwdc2020/10653/)
  - 利用リクエスト
    - VNDetectHumanHandPoseRequest

### 軌跡検出

- [11. ビデオ内の移動オブジェクトの検出](https://developer.apple.com/documentation/vision/detecting_moving_objects_in_a_video)
  - Vision を使用して、投げられたオブジェクトの軌道を識別します。
  - 利用リクエスト
    - VNDetectTrajectoriesRequest

### テキスト認識

- [12. ドキュメント上の認識されたテキストの構造化](https://developer.apple.com/documentation/vision/structuring_recognized_text_on_a_document)
  - Vision と VisionKit を使用して、名刺またはレシートのテキストを検出、認識、構造化します。
  - [参考ビデオ](https://developer.apple.com/videos/play/wwdc2019/234)
  - 利用リクエスト
    - VNRecognizeTextRequest
  
- [13. 電話番号をリアルタイムで読み取る](https://developer.apple.com/documentation/vision/reading_phone_numbers_in_real_time)
  - ライブ キャプチャで認識されたテキストから電話番号を分析およびフィルタリングし、時間の経過とともに証拠を構築します。
  - [参考ビデオ](https://developer.apple.com/videos/play/wwdc2019/234)
  - 利用リクエスト
    - VNRecognizeTextRequest

- [14. 認識されたテキストの検索と表示](https://developer.apple.com/documentation/vision/locating_and_displaying_recognized_text)
  - 画像のテキスト認識を構成して実行し、テキスト コンテンツを識別します。
  - [参考ビデオ](https://developer.apple.com/videos/play/wwdc2021/10041/)
  - 利用リクエスト
    - VNRecognizeTextRequest

### 画像の配置

- [15. 類似画像の整列](https://developer.apple.com/documentation/vision/aligning_similar_images)
  - 同じシーンをキャプチャした画像から合成画像を作成します。
  - swiftUI ベースのプロジェクト
  - 利用リクエスト
    - (VNImageRegistrationRequest)
    - VNTranslationalImageRegistrationRequest
    - VNHomographicImageRegistrationRequest

### 物体認識

- [16. ライブ キャプチャでのオブジェクトの認識](https://developer.apple.com/documentation/vision/recognizing_objects_in_live_capture)
  - Vision アルゴリズムを適用して、リアルタイム ビデオ内のオブジェクトを識別します。
  - 利用リクエスト
    - VNCoreMLRequest

- [17. Vision と物体検出モデルによるサイコロの振りを理解する](https://developer.apple.com/documentation/vision/understanding_a_dice_roll_with_vision_and_object_detection)
  - カメラ フレームに表示されたサイコロの位置と値を検出し、サイコロ検出モデルを利用してロールの終わりを判断します。
  - [参考ビデオ](https://developer.apple.com/videos/play/wwdc2019/228)
  - 利用リクエスト
    - VNCoreMLRequest

### 機械学習による画像解析

- [18. Vision と Core ML を使用した画像の分類](https://developer.apple.com/documentation/vision/classifying_images_with_vision_and_core_ml)
  - Vision フレームワークを使用して写真をトリミングおよびスケーリングし、Core ML モデルで分類します。
  - 利用リクエスト
    - VNImageBasedRequest
    - VNCoreMLRequest

- [19. 花を分類するための Create ML モデルのトレーニング](https://developer.apple.com/documentation/vision/training_a_create_ml_model_to_classify_flowers)
  - Swift Playgrounds で Create ML を使用して花の分類子をトレーニングし、結果のモデルを Vision を使用してリアルタイムの画像分類に適用します。
  - 利用リクエスト
    - VNDetectBarcodesRequest
    - VNCoreMLRequest
    - VNTranslationalImageRegistrationRequest

---

## 本リポジトリのサンプル一覧

各サンプルは、以下に記載の公式サンプルを参考に実装しています。

それぞれのサンプルについては参考元のライセンスに準じます。(各プロジェクト内にLISENSEファイルを格納しています)

### 輪郭検出

カメラプレビュー機能の利用において、以下プロジェクトを参考にしています。

- [Recognizing Objects in Live Capture](https://developer.apple.com/documentation/vision/recognizing_objects_in_live_capture)

### 人体検出

カメラプレビュー機能の利用において、以下プロジェクトを参考にしています。

- [Recognizing Objects in Live Capture](https://developer.apple.com/documentation/vision/recognizing_objects_in_live_capture)

バウンディングボックスの描画において、以下のプロジェクトを参考にしています。

- [Detecting Objects in Still Images](https://developer.apple.com/documentation/vision/detecting_objects_in_still_images)

### 体の姿勢

カメラプレビュー機能の利用において、以下プロジェクトを参考にしています。

- [Recognizing Objects in Live Capture](https://developer.apple.com/documentation/vision/recognizing_objects_in_live_capture)

その他参考サイト

- [Detecting Human Body Poses in Images](https://developer.apple.com/documentation/vision/detecting_human_body_poses_in_images)

### 動物認識

カメラプレビュー機能の利用において、以下プロジェクトを参考にしています。

- [Recognizing Objects in Live Capture](https://developer.apple.com/documentation/vision/recognizing_objects_in_live_capture)

### 水平検出

フォトライブラリの画像利用、及びバウンディングボックスの描画において、以下プロジェクトを参考にしています。

- [Detecting Objects in Still Images](https://developer.apple.com/documentation/vision/detecting_objects_in_still_images)

### オプティカルフロー

VNPixelBufferObservation の利用において、以下プロジェクトを参考にしています。

- [Applying Matte Effects to People in Images and Video](https://developer.apple.com/documentation/vision/applying_matte_effects_to_people_in_images_and_video)

### 書類検出

カメラプレビュー機能の利用において、以下プロジェクトを参考にしています。

- [Recognizing Objects in Live Capture](https://developer.apple.com/documentation/vision/recognizing_objects_in_live_capture)

バウンディングボックスの描画において、以下のプロジェクトを参考にしています。

- [Detecting Objects in Still Images](https://developer.apple.com/documentation/vision/detecting_objects_in_still_images)
