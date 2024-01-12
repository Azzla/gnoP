local Shaders = {}

function Shaders:loadShader(moonshine, shader_name)
	local shader = assert(self[shader_name], "No such shader exists.")

	return moonshine.Effect{
		name = shader_name,
		shader = shader,
		setters = {iResolution = function(v) shader:send("iResolution", v) end},
		defaults = {iResolution = {2560,1440}}
	}
end

Shaders.vhs_pause = love.graphics.newShader([[
	extern vec2 iResolution;
	extern float iTime;

	float rand(vec2 co){
	    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
	}

	vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
	{
	    vec4 texColor = vec4(0);
	    // get position to sample
	    vec2 samplePosition = screen_coords.xy / iResolution.xy;
	    float whiteNoise = 9999.0;
	    
	 	// Jitter each line left and right
	    samplePosition.x = samplePosition.x+(rand(vec2(iTime,texture_coords.y))-0.5)/64.0;
	    // Jitter the whole picture up and down
	    samplePosition.y = samplePosition.y+(rand(vec2(iTime))-0.5)/32.0;
	    // Slightly add color noise to each line
	    texColor = texColor + (vec4(-0.5)+vec4(rand(vec2(texture_coords.y,iTime)),rand(vec2(texture_coords.y,iTime+1.0)),rand(vec2(texture_coords.y,iTime+2.0)),0))*0.1;
	   
	    // Either sample the texture, or just make the pixel white (to get the staticy-bit at the bottom)
	    whiteNoise = rand(vec2(floor(samplePosition.y*80.0),floor(samplePosition.x*50.0))+vec2(iTime,0));
	    if (whiteNoise > 11.5-35.0*samplePosition.y || whiteNoise < 1.5-5.0*samplePosition.y) {
	        // Sample the texture.
	    	//samplePosition.y = 1.0-samplePosition.y; //Fix for upside-down texture
	    	texColor = texColor + Texel(texture, samplePosition);
	    } else {
	        // Use white. (I'm adding here so the color noise still applies)
	        texColor = vec4(1);
	    }
		
		return texColor;
	}
]])

Shaders.vignette = love.graphics.newShader([[
	extern vec2 iResolution;
	vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
	{
		vec2 uv = screen_coords.xy / iResolution.xy;
	   
	    uv *=  1.0 - uv.yx;   //vec2(1.0)- uv.yx; -> 1.-u.yx; Thanks FabriceNeyret !
	    
	    float vig = uv.x*uv.y * 15.0; // multiply with sth for intensity
	    
	    vig = pow(vig, 0.25); // change pow for modifying the extend of the  vignette

	    return vec4(vig);
	}
]])

Shaders.crt_filter = love.graphics.newShader([[
	extern vec2 iResolution;           // viewport resolution (in pixels)

	//	Choose one of these to change the style of the crt
	//#define X_ONLY
	//#define Y_ONLY
	#define X_AND_Y

	// Will return a value of 1 if the 'x' is < 'value'
	float Less(float x, float value)
	{
		return 1.0 - step(value, x);
	}

	// Will return a value of 1 if the 'x' is >= 'lower' && < 'upper'
	float Between(float x, float  lower, float upper)
	{
	    return step(lower, x) * (1.0 - step(upper, x));
	}

	//	Will return a value of 1 if 'x' is >= value
	float GEqual(float x, float value)
	{
	    return step(value, x);
	}

	vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
	{
	    float brightness = 1.25;
		vec2 uv = screen_coords.xy / iResolution.xy;
	    uv.y = -uv.y;
	    //uv = uv * 0.05;
	    
	    vec2 uvStep;
	    uvStep.x = uv.x / (1.0 / iResolution.x);
	    uvStep.x = mod(uvStep.x, 3.0);
	    uvStep.y = uv.y / (1.0 / iResolution.y);
	    uvStep.y = mod(uvStep.y, 3.0);
	    
	    vec4 newColour = Texel(texture, uv);
	    
		#ifdef X_ONLY
		    newColour.r = newColour.r * Less(uvStep.x, 1.0);
		    newColour.g = newColour.g * Between(uvStep.x, 1.0, 2.0);
		    newColour.b = newColour.b * GEqual(uvStep.x, 2.0);
		#endif
		    
		#ifdef Y_ONLY
		    newColour.r = newColour.r * Less(uvStep.y, 1.0);
		    newColour.g = newColour.g * Between(uvStep.y, 1.0, 2.0);
		    newColour.b = newColour.b * GEqual(uvStep.y, 2.0);
		#endif
		    
		#ifdef X_AND_Y
		    newColour.r = newColour.r * step(1.0, (Less(uvStep.x, 1.0) + Less(uvStep.y, 1.0)));
		    newColour.g = newColour.g * step(1.0, (Between(uvStep.x, 1.0, 2.0) + Between(uvStep.y, 1.0, 2.0)));
		    newColour.b = newColour.b * step(1.0, (GEqual(uvStep.x, 2.0) + GEqual(uvStep.y, 2.0)));
		#endif
	    
		return newColour * brightness;
	}
]])

return Shaders