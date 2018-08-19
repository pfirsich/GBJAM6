out vec2 texCoord;

layout(location = KAUN_ATTR_POSITION) in vec2 attrPosition;

uniform vec2 viewportScale;
uniform vec2 viewportOffset;

void main() {
    texCoord = attrPosition * 0.5 + 0.5;
    vec2 pos = texCoord;
    pos.y = 1.0 - pos.y;
    pos = pos * viewportScale + viewportOffset;
    pos.y = 1.0 - pos.y;
    gl_Position = vec4(pos * 2.0 - 1.0, 0.0, 1.0);
}
