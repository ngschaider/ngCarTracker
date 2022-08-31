function setup() {
	const size = windowWidth * 0.2;
	createCanvas(size, size);
	lineLength = size / 2 + 5;
}

let lineLength;

const rotationDuration = 5000;
let rotation = 0;
let points = [];
let arrows = [];



const hueStart = 0;
const hueEnd = 120;
const saturation = 50;
const brightness = 100;
const rings = 4;

function draw() {
	background(72, 87, 70);
	translate(width/2, height/2);
	
	noFill();
	strokeWeight(2);
	colorMode(HSL, 255);
	for(let ringIndex = 1; ringIndex <= rings; ringIndex++) {
		const radius = width / rings * ringIndex - 1;
		const hue = (hueEnd - hueStart) / rings * ringIndex + hueStart;
		
		stroke(hue, saturation, brightness);
		ellipse(0, 0, radius, radius);
	}
	colorMode(RGB, 255);
	
	
	noFill();
	colorMode(HSL, 255);
	stroke(hueEnd, saturation, brightness);
	strokeWeight(1);
	line(0, -height/2, 0, height/2);
	line(-width/2, 0, width/2, 0);
	colorMode(RGB, 255);
	


	noStroke();
	fill(0, 247, 0);
	ellipse(0, 0, 20, 20);
	
	
	const lineX = lineLength * Math.cos(rotation);
	const lineY = lineLength * Math.sin(rotation);
	strokeWeight(2);
	stroke(0, 247, 0, 200);
	fill(0, 247, 0);
	line(0, 0, lineX, lineY);
	
	for(const target of targets) {
		let x = target.x * width/2;
		let y = target.y * height/2;
		
		let angle = Math.atan2(y, x);
		if(angle < 0) {
			angle += 2 * Math.PI;
		}
		
		if(Math.abs(angle - rotation) <= 0.1) {
			if(Math.sqrt(target.x * target.x + target.y * target.y) >= 1.0) {
				arrows.push({
					angle: angle,
					opacity: 200,
				});
			} else {
				points.push({
					x: x, 
					y: y,
					opacity: 200,
				});
			}
		}
	}
	
	rotation += 2 * Math.PI / rotationDuration * deltaTime;
	if(rotation >= 2 * Math.PI) {
		rotation -= 2 * Math.PI;
	}
	
	for(const point of points) {
		if(point.opacity > 0) {
			strokeWeight(4);
			noStroke();
			fill(0, 247, 0, point.opacity);
			ellipse(point.x, point.y, 10, 10);
			point.opacity -= 2;
		}
	}
	
	for(const arrow of arrows) {
		push();
		strokeWeight(4);
		noStroke();
		fill(0, 247, 0, arrow.opacity);
		rotate(arrow.angle);
		translate(width / 2, 0);
		line(0, 0, -10, -10);
		line(0, 0, -10, 10);
		line(-10, -10, -10, 10);
		triangle(0, 0, -10, -10, -10, 10);
		ellipse(0, 0, 2, 2);
		pop();
		arrow.opacity -= 2;
	}
}


let targets = [];

const SetTargets = (newTargets) => {
	targets = newTargets;
};

const Show = () => {
	$("body").removeClass("d-none");
}

const Hide = () => {
	$("body").addClass("d-none");
}

const Toggle = () => {
	$("body").toggleClass("d-none");
}

const SendRequest = (name, data) => {
	fetch("https://" + GetParentResourceName() + "/" + name, {
    	method: 'POST',
    	headers: {
			'Content-Type': 'application/json; charset=UTF-8',
    	},
    	body: data ? JSON.stringify(data) : {},
	}).then(res => {
	});
}

window.addEventListener('message', (event) => {
	if(event.data.name) {
		try {
			if(event.data.args) {
				eval(event.data.name + "(...event.data.args);");
			} else {
				eval(event.data.name + "();");
			}
			
		} catch(e) {
			console.error("Error while executing NUI message '" + event.data.name + "'");
			console.log(e);
		}
	}
});