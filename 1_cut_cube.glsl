const float EPS = 0.01;

const float PI_2 = 1.570796326795;

const vec3 BLACK_COLOR = vec3(0.06);
const vec3 WHITE_COLOR = vec3(0.60);

const vec3 cameraOrigin = vec3(500.0, 500.0, 500.0);
const vec3 cameraTarget = vec3(0.0, 0.0, 0.0);
const vec3 upDirection = vec3(0.0, 1.0, 0.0);

const mat3 ROTATION_90_Y = mat3(
  0, 0, 1,
  0, 1, 0,
  -1, 0, 0
);

const mat3 ROTATION_90_X = mat3(
  1, 0, 0,
  0, 0, 1,
  0, -1, 0
);

const mat3 ROTATION_90_Z = mat3(
  0, -1, 0,
  -1, 0, 0,
  0, 0, 1
);

const vec3 lightPosition = vec3(50, 50, 50);

int gMaterialId;

mat3 rotationMatrix(vec3 axis, float angle) {
  axis = normalize(axis);
  float s = sin(angle);
  float c = cos(angle);
  float oc = 1.0 - c;

  return mat3(
      oc * axis.x * axis.x + c, oc * axis.x * axis.y - axis.z * s,
      oc * axis.z * axis.x + axis.y * s, oc * axis.x * axis.y + axis.z * s,
      oc * axis.y * axis.y + c, oc * axis.y * axis.z - axis.x * s,
      oc * axis.z * axis.x - axis.y * s, oc * axis.y * axis.z + axis.x * s,
      oc * axis.z * axis.z + c);
}

float innerCube(vec3 p, float animationTime) {
    float finalValue;
    vec3 q = p;
    
    float x = animationTime * 0.85 - 0.05;
    float t = clamp(x<0.5 ? 4.0*x*x*x : (x-1.0)*(2.0*x-2.0)*(2.0*x-2.0)+1.0, 0.0, 1.0);
    float val = mix(0.0, -PI_2, t);
    
    mat3 cubeRotation = rotationMatrix(vec3(0,1.0,0), val);
    q = vec3(inverse(cubeRotation) * p);

    vec3 b = vec3(20.0);
    vec3 d = abs(q) - b;
    finalValue = min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));

    if (finalValue < EPS) {
        gMaterialId = 0;
        
        if ((abs(q.x) > 19.0 && abs(q.y) > 19.0) ||
           (abs(q.y) > 19.0 && abs(q.z) > 19.0) ||
           (abs(q.z) > 19.0 && abs(q.x) > 19.0))
        {
            gMaterialId = 1;
        }
    }
    
    return finalValue;
}

float sideRing(vec3 p, float animationTime, float delta, float delay, bool useZ, float translateDirection) {
  float finalValue;
    
    float t,x;
    
    vec3 q1 = p;
    float translationDiff;
    
    x = animationTime * 1.25;
    float t1 = clamp(x<0.5 ? 4.0*x*x*x : (x-1.0)*(2.0*x-2.0)*(2.0*x-2.0)+1.0, 0.0, 1.0);
    x = -animationTime * 1.25 + 2.80;
    float t2 = clamp(x<0.5 ? 4.0*x*x*x : (x-1.0)*(2.0*x-2.0)*(2.0*x-2.0)+1.0, 0.0, 1.0);\
  t = min(t1, t2);
    
    translationDiff = t * 10.0 * translateDirection;
    
    animationTime -= delay;
    
    x = animationTime * 0.85 - 0.05;
    t = clamp(x<0.5 ? 4.0*x*x*x : (x-1.0)*(2.0*x-2.0)*(2.0*x-2.0)+1.0, 0.0, 1.0);
    vec3 finalQ = (inverse(rotationMatrix(useZ ? vec3(0, 0.0, 1.0) : vec3(0, 1.0, 0.0), mix(0.0, -PI_2, t))) * q1) - vec3(0,0, 35.0 + delta + translationDiff);

    vec3 d = abs(finalQ) - vec3(20.0, 20.0, 0.2);
    finalValue = min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
    
    if (finalValue < EPS) {
        gMaterialId = 0 + int(ceil(step(19.0, abs(finalQ.y)) * 0.5 + step(19.0, abs(finalQ.x))* 0.5));
    }
    
  return finalValue;
}

float sceneSDF(vec3 p) {
    float finalDistance;
    vec3 q;
    
    float milliSecs = iTime * 1000.0f;
    
    float animationTime = mod(iTime * 1.25, 1.95);
    
    finalDistance = innerCube(p, animationTime);    
    
    q = p;
    
    float sideRings = 9999.0;
    
    for(int i = 0; i < 4; ++i) {
        sideRings = min(sideRings, sideRing(q, animationTime, 0.0, 0.0, false, 1.0));
        sideRings = min(sideRings, sideRing(q, animationTime, 15.0, 0.18, false, 1.0));
        sideRings = min(sideRings, sideRing(q, animationTime, 30.0, 0.36, false, 1.0));
        sideRings = min(sideRings, sideRing(q, animationTime, 38.0, 0.54, false, 1.0));
        sideRings = min(sideRings, sideRing(q, animationTime, 46.0, 0.72, false, 1.0));
        sideRings = min(sideRings, sideRing(q, animationTime, 54.0, 0.90, false, 1.0));
        q = ROTATION_90_Y * q;
    }
    
    q = ROTATION_90_X * p;
    float topRings = sideRing(q, animationTime, 0.0, 0.0, true, 1.0);
    topRings = min(topRings, sideRing(q, animationTime, 15.0, 0.1, true, 1.0));
    topRings = min(topRings, sideRing(q, animationTime, 30.0, 0.2, true, 1.0));
    topRings = min(topRings, sideRing(q, animationTime, 38.0, 0.3, true, 1.0));
    topRings = min(topRings, sideRing(q, animationTime, 46.0, 0.4, true, 1.0));
    topRings = min(topRings, sideRing(q, animationTime, 54.0, 0.5, true, 1.0));
    
    q = ROTATION_90_X * p - vec3(0,0,-40);
    float botRings = sideRing(q, animationTime, -30.0, 0.0, true, -1.0);
    botRings = min(botRings, sideRing(q, animationTime, -45.0, 0.1, true, -1.0));
    botRings = min(botRings, sideRing(q, animationTime, -60.0, 0.2, true, -1.0));
    botRings = min(botRings, sideRing(q, animationTime, -68.0, 0.3, true, -1.0));
    botRings = min(botRings, sideRing(q, animationTime, -76.0, 0.3, true, -1.0));
    botRings = min(botRings, sideRing(q, animationTime, -84.0, 0.4, true, -1.0));

    finalDistance = min(finalDistance, topRings);
    finalDistance = min(finalDistance, botRings);
    finalDistance = min(finalDistance, sideRings);
    
    return finalDistance;
}

bool rayMarchScene(in vec3 rayOrigin, in vec3 rayDir, out float finalValue) {
  float dist = 0.0;
  float eps = 0.001;

  for (int step = 0; step < 50; ++step) {
    vec3 position = rayOrigin + dist * rayDir;

    float dt = sceneSDF(position);

    if (dt < eps) {
      finalValue = dist;
      return true;
    }

    dist += dt;
  }

  return false;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    gMaterialId = 0;
    vec3 finalColor = BLACK_COLOR;
    
    vec3 cameraDir = normalize(cameraTarget - cameraOrigin);
    vec3 cameraRight = normalize(cross(cameraDir, upDirection));
    vec3 cameraUp = cross(cameraRight, cameraDir);
    
    vec2 ndc = -1.0 + 2.0 * gl_FragCoord.xy / iResolution.xy; // screenPos can range from -1 to 1
    ndc.x *= iResolution.x / iResolution.y;
    ndc.y *= -1.0;
    
    vec3 rayDir = normalize(cameraRight * ndc.x + cameraUp * ndc.y + cameraDir);
    vec3 rayOrigin = cameraOrigin;

    vec2 s_pos =  (2.0 * fragCoord - iResolution.xy)  / iResolution.y;
    
    s_pos *= 200.0;
    
    // up vector
    vec3 up = vec3(0.0, 1.0, 0.0);
    
    // camera position
  vec3 c_pos = vec3(100.0, 100.0, 100.0);
    // camera target
    vec3 c_targ = vec3(0.0, 0.0, 0.0);
    // camera direction
    vec3 c_dir = normalize(c_targ - c_pos);
    // camera right
    vec3 c_right = cross(c_dir, up);
    // camera up
    vec3 c_up = cross(c_right, c_dir);
    // camera to screen distance
    float c_sdist = 2.0;
    
    // compute the ray direction
    rayDir = normalize(c_dir);
    // ray progress, just begin at the cameras position
    rayOrigin = c_pos + c_right * s_pos.x + c_up * s_pos.y;
    
    
    float dist;
    
    bool sceneIntersection = rayMarchScene(rayOrigin, rayDir, dist);
    
    vec3 finalPosition;
    vec3 finalNormal;
    
    if (sceneIntersection) {
        finalPosition = rayOrigin + dist * rayDir;

        float eps = 0.001;
        float dx = sceneSDF(finalPosition + vec3(eps, 0, 0)) -
                   sceneSDF(finalPosition - vec3(eps, 0, 0));
        float dy = sceneSDF(finalPosition + vec3(0, eps, 0)) -
                   sceneSDF(finalPosition - vec3(0, eps, 0));
        float dz = sceneSDF(finalPosition + vec3(0, 0, eps)) -
                   sceneSDF(finalPosition - vec3(0, 0, eps));

        finalNormal = normalize(vec3(dx, dy, dz));
        
        float diffuseTerm = max(0.0, dot(normalize(finalNormal), normalize(lightPosition)));
        float specularTerm = 0.0;
        
        
        
        if (diffuseTerm > 0.0) {
            vec3 viewVec = normalize(cameraOrigin - finalPosition);
            vec3 lightVec = normalize(lightPosition - finalPosition);

            vec3 R = normalize(reflect(-lightVec, finalNormal));
            specularTerm = pow(max(0.0, dot(R, viewVec)), 128.0);
        }
        
        finalColor = BLACK_COLOR;
        
        if (gMaterialId == 1) {
            vec3 lightIntensity  = diffuseTerm * vec3(2.0,2.0,2.0);
            // finalColor = WHITE_COLOR;
            finalColor = lightIntensity * WHITE_COLOR + 1.5 * specularTerm;
        }
    }
    
    fragColor = vec4(finalColor, 1.0f);
}