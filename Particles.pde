/***********************************************************************
 * -----------------------------------
 * 
 * Copyright (c) 2008, Memo Akten, www.memo.tv
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 * 	
 ***********************************************************************/

import toxi.geom.*;

float MOUSE_VEL        = 1000.0;
float STIFFNESS        = 0.03;
float DAMPING          = 0.2;
float WORLD_BOUNDARY   = 1000.0;

/********************* Particle ***********************/
class Particle {

    Particle() {
        intensity  = 0;
        pos        = new Vec3D();
        homePos    = new Vec3D();
        homeDist   = new Vec3D();
        vel        = new Vec3D();
    }

    void init(float initX, float initY, float initZ, float initIntensity) {
        homePos.set(initX, initY, initZ);
        intensity = initIntensity;
    }

    void kill() {
        intensity = 0;
    }

    void setManager(ParticleManager _manager) {
        manager = _manager;
    }

    /****** main *******/
    Vec3D pos;			// current position
    Vec3D homePos;              // home position
    Vec3D homeDist;
    Vec3D vel;                  // velocity
    float intensity;		// color of particle
    float mouseDist2;            // distance^2 to mouse cursor
    float homeDist2;            // distance^2 to home position
    float scrX, scrY;           // screen coordinates

    ParticleManager manager;

    void update() {
        // if left mouse button down
        scrX = screenX(pos.x, pos.y, pos.z);
        scrY = screenY(pos.x, pos.y, pos.z);


        homeDist.x = homePos.x - pos.x;
        homeDist.y = homePos.y - pos.y;
        homeDist.z = homePos.z - pos.z;
        homeDist2 = homeDist.magSquared();
        if(mousePressed && mouseButton == LEFT) {
            //            if(!mousePressedLastFrame) {        // if it was pressed this frame, save influence
            float mouseDistX = mouseX - scrX;
            float mouseDistY = mouseY - scrY;
            mouseDist2 = mouseDistX * mouseDistX + mouseDistY * mouseDistY;
            //          }
            vel.x += MOUSE_VEL * mouseVelX / (mouseDist2 + 1000);
            vel.y += MOUSE_VEL * mouseVelY / (mouseDist2 + 1000);
            vel.z += (random(0, 1) - 0.5) * (mouseVelX * mouseVelX + mouseVelY * mouseVelY * 10)/ (mouseDist2 + 100);
        } 

        if(springOn) {
            vel.x += homeDist.x * STIFFNESS - vel.x * DAMPING;
            vel.y += homeDist.y * STIFFNESS - vel.y * DAMPING;
            vel.z += homeDist.z * STIFFNESS - vel.z * DAMPING;
        }

        // if(scrX < 0 || scrX > width) vel.x *= -1;
        // if(scrY < 0 || scrY > height) vel.y *= -1;

        if(pos.x < -WORLD_BOUNDARY) vel.x = abs(vel.x);
        else if(pos.x > WORLD_BOUNDARY) vel.x = -abs(vel.x);

        if(pos.y < -WORLD_BOUNDARY) vel.y = abs(vel.y);
        else if(pos.y > WORLD_BOUNDARY) vel.y = -abs(vel.y);

        if(pos.z < -WORLD_BOUNDARY) vel.z = abs(vel.z);
        else if(pos.z > WORLD_BOUNDARY) vel.z = -abs(vel.z);

        pos.x += vel.x;
        pos.y += vel.y;
        pos.z += vel.z;
    }

    void renderBox() {
        setColor(false);
        pushMatrix();
        translate(pos.x, pos.y, pos.z);
        box(particleSize); 
        popMatrix();
    }

    void renderSphere() {
        setColor(false);
        pushMatrix();
        translate(pos.x, pos.y, pos.z);
        sphere(particleSize*0.5);
        popMatrix();
    }


    void setColor(boolean bStroke) {
        if(bStroke)
            stroke(intensity, intensity * map(homeDist2, 0, width*height, 1, 0), intensity * map(homeDist2, 0, width*height/2, 1, 0));
        else 
            fill(intensity, intensity * map(homeDist2, 0, width*height, 1, 0), intensity * map(homeDist2, 0, width*height/2, 1, 0));
    }

    void renderPoint(boolean bStroke) {
        setColor(bStroke);
        vertex(pos.x, pos.y, pos.z);
    }

};



/********************* Particle Manager ***********************/
class ParticleManager {
    Particle []particles;

    ParticleManager() {
    }

    void init(float _maxSpeed, int _maxCount) {
        maxSpeed		= _maxSpeed;
        maxCount		= _maxCount;
        particles		= new Particle[maxCount];
        for(int c=0; c<maxCount; c++) particles[c] = new Particle();
    }

    void updateAndRender() {
        switch(renderMode) {

        case RENDER_BOX:
            for(int c=0; c<maxCount; c++) {
                if(particles[c].intensity > 0) {
                    particles[c].update();
                    particles[c].renderBox();
                }
            }
            break;

        case RENDER_SPHERE:
            for(int c=0; c<maxCount; c++) {
                if(particles[c].intensity > 0) {
                    particles[c].update();
                    particles[c].renderSphere();
                }
            }
            break;

        case RENDER_POINT:
            beginShape(POINTS);
            for(int c=0; c<maxCount; c++) {
                if(particles[c].intensity > 0) {
                    particles[c].update();
                    particles[c].renderPoint(true);
                }
            }     
            endShape(); 
            noStroke();    
            break;

        case RENDER_STRIP:
            for(int c=0; c<maxCount; c++) {
                if(particles[c].intensity > 0) {
                    particles[c].update();
                }
            }
            Particle tl, tr, bl, br;	// top left, top right, bottom left, bottom right particles
            int index;
            for(int j=0; j < GRIDY - 1; j++) {
                beginShape(QUAD_STRIP);
                for(int i=0; i < GRIDX - 1; i++) {
                    index = j * GRIDX + i;
                    tl = particles[index];
                    tr = particles[index + 1];
                    bl = particles[index + GRIDX];
                    br = particles[index + GRIDX + 1];

                    tl.renderPoint(false);		
                    bl.renderPoint(false);		
                    tr.renderPoint(false);		
                    br.renderPoint(false);		
                }
                endShape();
            }
            break;
        }
    }


    float    maxSpeed;
    int      maxCount;

};

