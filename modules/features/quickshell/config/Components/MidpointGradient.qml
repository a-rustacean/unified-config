import QtQuick
import QtQuick.Shapes

Item {
  id: root

  property real angle: 0        // Degrees; 0 = transparent left, colour right
  readonly property real angleRadians: angle * Math.PI / 180.0
  property real blur: 0.0       // 0 = sharp, 1 = very soft

  // Public API
  property color color: "#4da3ffff"

  // Half the diagonal ensures the gradient covers the entire item.
  readonly property real gradientRadius: Math.sqrt(width * width + height * height) / 2.0
  property real midpoint: 0.5   // 0..1
  property double radius: 10
  readonly property real safeBlur: Math.max(blur, 0.00001)
  readonly property real safeMidpoint: clamp01(midpoint)
  readonly property real transitionEnd: clamp01(safeMidpoint + safeBlur / 2.0)
  readonly property real transitionStart: clamp01(safeMidpoint - safeBlur / 2.0)
  readonly property color transparentColor: Qt.rgba(color.r, color.g, color.b, 0.0)

  function clamp01(value) {
	return Math.max(0.0, Math.min(1.0, value));
  }

  Behavior on color {
	ColorAnimation {
	  duration: 100
	}
  }

  Shape {
	anchors.fill: parent
	preferredRendererType: Shape.CurveRenderer

	ShapePath {
	  strokeWidth: -1

	  fillGradient: LinearGradient {
		x1: root.width / 2.0 - root.gradientRadius * Math.cos(root.angleRadians)
		x2: root.width / 2.0 + root.gradientRadius * Math.cos(root.angleRadians)
		y1: root.height / 2.0 - root.gradientRadius * Math.sin(root.angleRadians)
		y2: root.height / 2.0 + root.gradientRadius * Math.sin(root.angleRadians)

		GradientStop {
		  color: root.transparentColor
		  position: 0.0
		}

		GradientStop {
		  color: root.transparentColor
		  position: root.transitionStart
		}

		GradientStop {
		  color: root.color
		  position: root.transitionEnd
		}

		GradientStop {
		  color: root.color
		  position: 1.0
		}
	  }

	  PathRectangle {
		height: root.height
		radius: Math.min(root.radius, Math.min(width, height) / 2.0)
		width: root.width
	  }
	}
  }
}
