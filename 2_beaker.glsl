#define EPS 0.001

const float COS_63 = 0.45399049974;
const float SIN_63 = 0.89100652418;

#define M_PI 3.14159265358979323846

const vec3 BLACK_COLOR = vec3(0.2);
const vec3 WHITE_COLOR = vec3(1.0);

const vec3 BLUE_1 = vec3(0.008, 0.6, 1.0);
const vec3 BLUE_2 = vec3(0.28, 0.82, 1.0);
const vec3 BLUE_3 = vec3(0.41, 0.91, 1.0);
const vec3 BLUE_4 = vec3(0.30, 0.54, 0.59);

const vec3 TEST = vec3(1.0, 0.0, 1.0);

int gMaterialId;
float gLerpAmount;
float gAlpha;

float sdBox( vec2 p, vec2 b )
{
  vec2 d = abs(p) - b;
  return min(max(d.x, d.y),0.0) + length(max(d,0.0));
}

float rand(float n){return fract(sin(n) * 43758.5453123);}

float noise(float p){
  float fl = floor(p);
  float fc = fract(p);
  return mix(rand(fl), rand(fl + 1.0), fc);
}

float fbm(float x) {
  float v = 0.0;
  float a = 0.5;
  float shift = float(100);
  for (int i = 0; i < 8; ++i) {
    v += a * abs(1.0 - noise(x));
    x = x * 2.0 + shift;
    a *= 0.5;
  }
    
  return v * 10.0;
}
float f1(float x) {
    return x<0.5 ? 4.0*x*x*x : (x-1.0)*(2.0*x-2.0)*(2.0*x-2.0)+1.0;
}

float sceneSDF(vec2 p) {
    float finalDistance;

    vec2 q = p;
    
    finalDistance = length(p - vec2(-14.0, 0)) - 10.0;
    
    finalDistance = min(finalDistance, length(p - vec2(14.0, 0)) - 10.0);
    
    finalDistance = min(finalDistance, sdBox(p -vec2(0, -0.2), vec2(14.0, 9.95)));
    
    q = p - vec2(6.8, 14.0);
    q = vec2(q.x * COS_63 + q.y * -SIN_63, q.x * SIN_63 + q.y * COS_63);
    finalDistance = min(finalDistance, sdBox(q, vec2(14.0, 9.95)));
    
    q = p - vec2(-6.8, 14.0);
    q = vec2(q.x * COS_63 + q.y * SIN_63, q.x * -SIN_63 + q.y * COS_63);
    finalDistance = min(finalDistance, sdBox(q, vec2(14.0, 9.95)));
    
    q = p - vec2(0.0, 27.5);
    finalDistance = min(finalDistance, sdBox(q, vec2(10.0, 15.0)));
    
    q = p - vec2(0.0, 43.0);
    finalDistance = min(finalDistance, sdBox(q, vec2(15.0, 1.5)));
    
    finalDistance = min(finalDistance, length(p - vec2(15.0, 43.0)) - 1.5);
    finalDistance = min(finalDistance, length(p - vec2(-15.0, 43.0)) - 1.5);
    
    if (finalDistance < EPS) {
        gMaterialId = 1;
    }
    
    float liquid = length(p - vec2(-11.5, 0)) - 5.0;
    
    liquid = min(liquid, length(p - vec2(11.5, 0)) - 5.0);
    
    liquid = min(liquid, sdBox(p -vec2(0, 0.0), vec2(10.0, 5.0)));
    
    q = p - vec2(4.53, 9.5);
    q = vec2(q.x * COS_63 + q.y * -SIN_63, q.x * SIN_63 + q.y * COS_63);
    liquid = min(liquid, sdBox(q, vec2(12.0, 7.0)));
    
    q = p - vec2(-4.53, 9.5);
    q = vec2(q.x * COS_63 + q.y * SIN_63, q.x * -SIN_63 + q.y * COS_63);
    liquid = min(liquid, sdBox(q, vec2(13.0, 7.0)));

    q = p - vec2(0.0, 20.0);
    float cutLiquid = sdBox(q, vec2(30.0, 5.0));
  liquid = max(-cutLiquid, liquid);
    
  if (liquid < EPS) {
        gMaterialId = 2;
    }
    
    float milliSecs = iTime * 1000.0f;
    
    float bubbles, bubbles2, bubble;
    float opScale;
    
    finalDistance = min(finalDistance, liquid);
    

  float val = 6.0 * M_PI * (fract(iTime * 0.07) - 0.5) * 2.0;
    
    float x = -1.0 * p.x * 0.05 + val + (M_PI / 2.3);
    float noiseShift = 0.2 * fbm(x + mod(iTime * 0.05, abs(val)));
    
    float waveDist1 = ((sin(5.3*x)/x + 1.0) + (sin(2.0*(x * 0.7))/(x * 3.5)) * 3.7) + 19.0 + noiseShift;
    
    if (p.y > 8.0 && p.y < waveDist1 && abs(p.x) < 12.0) {
        gMaterialId = 4;
        gLerpAmount = clamp((p.y - 8.0) / 10.0, 0.0, 1.0);
    }

    
    x = p.x * 0.05 + val;
    noiseShift = 0.2 * fbm(x + mod(iTime * 0.05, abs(val)));
    
    waveDist1 = 0.8 * (-(sin(3.0*x)/x + 1.0) + (sin(2.0*(x * 2.3))/(x * 2.3)) * 4.0) + 20.0 + noiseShift;
    
    if (p.y > 8.0 && p.y < waveDist1 && abs(p.x) < 12.0) {
        gMaterialId = 3;
        gLerpAmount = clamp((p.y - 8.0) / 10.0, 0.0, 1.0);
    }
    
    q = p - vec2(13, 16.0);
    q = vec2(q.x * COS_63 + q.y * -SIN_63, q.x * SIN_63 + q.y * COS_63);
    float greyCut = sdBox(q, vec2(14.0, 3.4));
    
    q = p - vec2(-12.7, 16.0);
    q = vec2(q.x * COS_63 + q.y * SIN_63, q.x * -SIN_63 + q.y * COS_63);
    greyCut = min(greyCut, sdBox(q, vec2(14.0, 3.4)));
    
    finalDistance = min(finalDistance, greyCut);
    
    if (greyCut < EPS) {
        gMaterialId = 1;
    }
    
    if (val > -M_PI && val < M_PI * 1.5) {
        x = (p.y - 4.0) * 0.08;
        opScale = max(0.0, min(min(f1(x), 1.0), min(f1(-x + 10.0), 1.0)));
        q = p - vec2(-2.0,mod(iTime * 12.0, 13.0));
        bubble = length(q / opScale) - 3.0;
        bubble *= opScale;
        bubbles = bubble;


        x = (p.y) * 0.25;
        opScale = max(0.0, min(min(f1(x), 1.0), min(f1(-x + 4.0), 1.0)));
        q = p - vec2(4.0, mod(iTime * 16.0, 24.0));
        bubble = length(q / opScale) - 2.0;
        bubble *= opScale;
        bubbles = min(bubbles, bubble);


        x = (p.y) * 0.25;
        opScale = max(0.0, min(min(f1(x), 1.0), min(f1(-x + 4.0), 1.0)));
        q = p - vec2(9.0, mod(iTime * 13.0, 12.0));
        bubble = length(q / opScale) - 2.0;
        bubble *= opScale;
        bubbles = min(bubbles, bubble);



        x = (p.y - 2.0) * 0.25;
        opScale = max(0.0, min(min(f1(x), 1.0), min(f1(-x + 4.0), 1.0)));
        q = p - vec2(-8.5, mod(iTime * 13.0, 12.0));
        bubble = length(q / opScale) - 2.5;
        bubble *= opScale;
        bubbles = min(bubbles, bubble);
        if (bubbles < EPS) {        
            gMaterialId = 5;
        }
    }
    
    if (val > -M_PI * 0.8 && val < M_PI * 1.5) {
        x = (p.y - 16.0) * 0.05;
        opScale = max(0.0, min(min(f1(x), 1.0), min(f1(-x + 4.0), 1.0)));
        q = p - vec2(5.0, mod(iTime * 13.0, 36.0));
        bubble = length(q / opScale) - 3.0;
        bubble *= opScale;
        bubbles2 = bubble;

        x = (p.y - 18.0) * 0.05;
        opScale = max(0.0, min(min(f1(x), 1.0), min(f1(-x + 4.0), 1.0)));
        q = p - vec2(-2.0, mod(iTime * 13.0, 40.0));
        bubble = length(q / opScale) - 1.5;
        bubble *= opScale;
        bubbles2 = min(bubbles2, bubble);
        if (bubbles2 < EPS) {        
            gMaterialId = 4;
        }
    }
    

    return finalDistance;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec3 finalColor = WHITE_COLOR;
    gAlpha = 1.0;
    
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;

    float aspect = iResolution.x / iResolution.y;
    vec2 ndc = -1.0 + 2.0 * uv;
    ndc.x *= aspect;
    ndc *= 100.0;
    
    float dist = sceneSDF(ndc);
    
    if (dist < EPS) {
        if (gMaterialId == 1) {
          finalColor = BLACK_COLOR;
        } else if (gMaterialId == 2) {
            finalColor = BLUE_1;
        } else if (gMaterialId == 3) {
            finalColor = mix(BLUE_1, BLUE_2, gLerpAmount);
        } else if (gMaterialId == 4) {
            finalColor = BLUE_4;
        } else if (gMaterialId == 5) {
            finalColor = BLUE_3;
        }  else if (gMaterialId == 99) {
            finalColor = TEST;
        }
    }

    // Output to screen
    fragColor = vec4(finalColor, 1.0);
}