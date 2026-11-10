# frozen_string_literal: true

# GENERATED FILE - do not edit by hand. Regenerate with script/update_style_spec
# Source: @maplibre/maplibre-gl-style-spec@26.6.0

module Glug # :nodoc:
  # Names from the MapLibre style spec, exactly as upstream spells them
  module StyleSpec # rubocop:disable Metrics/ModuleLength
    VERSION = '26.6.0'

    LAYOUT = {
      'fill' => %w[
        fill-sort-key
        visibility
      ],
      'line' => %w[
        line-cap
        line-join
        line-miter-limit
        line-round-limit
        line-sort-key
        visibility
      ],
      'circle' => %w[
        circle-sort-key
        visibility
      ],
      'heatmap' => %w[
        visibility
      ],
      'fill-extrusion' => %w[
        visibility
        fill-extrusion-rounded-corner-distance
      ],
      'symbol' => %w[
        symbol-placement
        symbol-spacing
        symbol-avoid-edges
        symbol-sort-key
        symbol-z-order
        icon-allow-overlap
        icon-overlap
        icon-ignore-placement
        icon-optional
        icon-rotation-alignment
        icon-size
        icon-text-fit
        icon-text-fit-padding
        icon-image
        icon-rotate
        icon-padding
        icon-keep-upright
        icon-offset
        icon-anchor
        icon-pitch-alignment
        text-pitch-alignment
        text-rotation-alignment
        text-field
        text-font
        text-size
        text-max-width
        text-line-height
        text-letter-spacing
        text-justify
        text-radial-offset
        text-variable-anchor
        text-variable-anchor-offset
        text-anchor
        text-max-angle
        text-writing-mode
        text-rotate
        text-padding
        text-keep-upright
        text-transform
        text-offset
        text-allow-overlap
        text-overlap
        text-ignore-placement
        text-optional
        symbol-height-offset
        symbol-height-anchor
        visibility
      ],
      'raster' => %w[
        visibility
      ],
      'hillshade' => %w[
        visibility
      ],
      'color-relief' => %w[
        visibility
      ],
      'background' => %w[
        visibility
      ]
    }.each_value(&:freeze).freeze

    PAINT = {
      'fill' => %w[
        fill-antialias
        fill-opacity
        fill-layer-opacity
        fill-layer-blend
        fill-color
        fill-outline-color
        fill-translate
        fill-translate-anchor
        fill-pattern
      ],
      'line' => %w[
        line-opacity
        line-layer-opacity
        line-layer-blend
        line-color
        line-translate
        line-translate-anchor
        line-width
        line-gap-width
        line-offset
        line-blur
        line-dasharray
        line-pattern
        line-gradient
      ],
      'circle' => %w[
        circle-radius
        circle-color
        circle-blur
        circle-opacity
        circle-translate
        circle-translate-anchor
        circle-pitch-scale
        circle-pitch-alignment
        circle-stroke-width
        circle-stroke-color
        circle-stroke-opacity
      ],
      'heatmap' => %w[
        heatmap-radius
        heatmap-weight
        heatmap-intensity
        heatmap-color
        heatmap-opacity
      ],
      'fill-extrusion' => %w[
        fill-extrusion-opacity
        fill-extrusion-color
        fill-extrusion-translate
        fill-extrusion-translate-anchor
        fill-extrusion-pattern
        fill-extrusion-height
        fill-extrusion-base
        fill-extrusion-vertical-gradient
      ],
      'symbol' => %w[
        icon-opacity
        icon-color
        icon-halo-color
        icon-halo-width
        icon-halo-blur
        icon-translate
        icon-translate-anchor
        text-opacity
        text-color
        text-halo-color
        text-halo-width
        text-halo-blur
        text-translate
        text-translate-anchor
      ],
      'raster' => %w[
        raster-opacity
        raster-layer-blend
        raster-hue-rotate
        raster-brightness-min
        raster-brightness-max
        raster-saturation
        raster-contrast
        resampling
        raster-resampling
        raster-fade-duration
      ],
      'hillshade' => %w[
        hillshade-illumination-direction
        hillshade-illumination-altitude
        hillshade-illumination-anchor
        hillshade-exaggeration
        hillshade-shadow-color
        hillshade-highlight-color
        hillshade-accent-color
        hillshade-method
        resampling
      ],
      'color-relief' => %w[
        color-relief-opacity
        color-relief-color
        resampling
      ],
      'background' => %w[
        background-color
        background-pattern
        background-opacity
      ]
    }.each_value(&:freeze).freeze

    EXPRESSIONS = %w[
      let
      var
      literal
      semiliteral
      array
      at
      in
      index-of
      slice
      case
      match
      coalesce
      step
      interpolate
      interpolate-hcl
      interpolate-lab
      ln2
      pi
      e
      typeof
      string
      number
      boolean
      object
      collator
      format
      image
      global-state
      number-format
      to-string
      to-number
      to-boolean
      to-rgba
      to-color
      rgb
      rgba
      get
      has
      length
      properties
      feature-state
      geometry-type
      id
      zoom
      heatmap-density
      elevation
      line-progress
      accumulated
      +
      *
      -
      /
      %
      ^
      sqrt
      log10
      ln
      log2
      sin
      cos
      tan
      asin
      acos
      atan
      min
      max
      round
      abs
      ceil
      floor
      distance
      ==
      !=
      >
      <
      >=
      <=
      all
      any
      !
      within
      is-supported-script
      upcase
      downcase
      concat
      resolved-locale
      split
      join
    ].freeze
  end
end
