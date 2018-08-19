in VSOUT {
    vec2 texCoord;
    vec3 normal;
    vec3 worldPos;
    vec3 eye;
} vsOut;

out vec4 fragColor;

uniform float groundSize;
uniform float tileSize;
uniform float gapSize;

void main() {
    vec2 tiles = vsOut.worldPos.xz / tileSize;
    vec2 tileCoord = fract(tiles);
    float gapRatio = gapSize / tileSize;
    float tileAmount = step(gapRatio, tileCoord.x) * step(gapRatio, tileCoord.y);
    float groundAmount = 1.0 - step(1.0, length(vsOut.worldPos.xz) / (groundSize / 2.0));
    fragColor = mix(vec4(0.0), vec4(1.0), tileAmount * groundAmount);
}
