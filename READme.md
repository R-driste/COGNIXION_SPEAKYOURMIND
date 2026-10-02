# COGNIXION — Speak Your Mind

This is a small side project I did for Cognixion Pilotcity + CS Assignment. It's a SwiftUI communication app prototype that helps people express short messages without needing to type a full sentence. It provides a phrase-based greeting board and an alphabet board, then speaks selected or composed text aloud. The greeting board also experiments with hands-free selection through ARKit eye tracking and emotion-adaptive speech.

<table width="100%">
	<tr>
		<td width="32%"><img src="pictures/Screenshot%202026-10-02%20at%202.13.51%E2%80%AFPM.png" alt="App screenshot 1" width="100%"></td>
		<td width="30%"><img src="pictures/Screenshot%202026-10-02%20at%202.14.31%E2%80%AFPM.png" alt="App screenshot 2" width="100%"></td>
		<td width="20%"><img src="pictures/Screenshot%202026-10-02%20at%202.15.02%E2%80%AFPM.png" alt="App screenshot 3" width="100%"></td>
	</tr>
</table>

## How it works

- **Menu:** The starting screen links to the greeting and letter boards.
- **Greet:** Choose from common phrases such as “Hello,” “Yes,” “Water,” and “I'm in Pain.” On supported devices, looking at a phrase for about three seconds selects it. The app uses the front TrueDepth camera and ARKit for gaze tracking, and the Mentalist package to analyze a captured face image and map the detected emotion to a voice mood.
- **Letter:** Tap letters and the space key to compose a message, then choose **Enter** to have it spoken with iOS text-to-speech.
- **Speech:** `AVSpeechSynthesizer` adjusts its rate and pitch for happy, sad, angry, or calm moods.

The project is a SwiftUI app configured for iOS 18.2 and includes unit-test and UI-test targets. Camera-based features need camera permission and compatible hardware; AR face tracking is skipped when the device does not support it. The Mentalist Swift package is declared in the Xcode project and should resolve when the project is opened.

## Run the app

1. Open `COGNIXION_SPEAKYOURMIND.xcodeproj` in Xcode.
2. Select the `COGNIXION_SPEAKYOURMIND` scheme and an iOS simulator or compatible device.
3. Build and run. Use a TrueDepth-capable device to try gaze selection and camera-based emotion analysis.

## Project layout

- `COGNIXION_SPEAKYOURMIND/` — SwiftUI screens, tab switching, speech, gaze tracking, and camera emotion analysis.
- `COGNIXION_SPEAKYOURMINDTests/` — unit-test target.
- `COGNIXION_SPEAKYOURMINDUITests/` — UI-test target.
- `pictures/` — screenshots shown below.

<!-- SCREENSHOTS:END -->
