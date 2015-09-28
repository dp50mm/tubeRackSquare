// Script to generate a tube radius
// All setting vars in milimeters


// To export, set the dimension variable in the BoxAsFletFile module to "2D"
// Click render, then export as SVG.


iTubes = 4;
jTubes = 4;



tubeRadius = 14.25; // mm
tubePadding = 5; // mm
tubeHeight = 100; // mm
holderHeight = 70; // mm
materialThickness = 3; // mm

bottomHolderZPosition = 20; // mm (measured from bottom of the box)

boltDiameter = 3; // mm
boltLength = 10; // mm
nutWidth = 5.6; // mm
nutHeight = 2.2; // mm
boltPosition = 2; // mm


teethWidth = 15; // mm
teethSpacing = 30; // mm

handHolderSize = 100; // mm
handHolderHeight = 20; // mm

laserCutPieceSpacing = 20; // mm (layout of 2d pieces)

// margin so that the teeth fit in the cutout.
laserCutLaserMargin = -0.05;

// CALCULATED VARS
connectionPadding = boltDiameter * 3;

boxLength = (tubeRadius*2+tubePadding)*iTubes+tubePadding+connectionPadding*2;
echo(str("boxLength calculated: ",boxLength,"mm"));

boxWidth = (tubeRadius*2+tubePadding)*jTubes+tubePadding+connectionPadding*2;
echo(str("boxWidth calculated: ",boxWidth,"mm"));

boxHeight = holderHeight;
echo(str("boxHeight same as holderHeight: ",boxHeight,"mm"));

boltPadding = boltDiameter*4;


numberOfTeeth = floor((boxLength-teethSpacing-boltPadding*2)/(teethWidth+teethSpacing));

echo(str("number of teeth is: ",numberOfTeeth));

module BoltSilhouetteCutout(dimensions)
{

    translate([0,-nutWidth/2,0]) {
        union() {
            translate([0,nutWidth/2-boltDiameter/2,0]) {
                if(dimensions == "3D") {
                    cube([boltLength-materialThickness+0.2,boltDiameter,materialThickness]);
                } else if(dimensions == "2D") {
                    square([depth,boltDiameter]);
                }
            }
            translate([boltPosition,0,0]) {
                if(dimensions == "3D") {
                    cube([nutHeight,nutWidth,materialThickness]);
                } else if(dimensions == "2D") {
                    square([nutHeight,nutWidth]);
                }
            }
        }
    }
}

module CornerBoltCutouts(dimensions)
{
    union() {
        translate([0,boltPadding,0]) {
            BoltSilhouetteCutout(dimensions);
        }
        translate([0,boxLength-boltPadding,0]) {
            BoltSilhouetteCutout(dimensions);
        }
        rotate([0,0,180]) {
            translate([-boxWidth+materialThickness*2,-boltPadding,0]) {
                BoltSilhouetteCutout(dimensions);
            }
        }
        rotate([0,0,180]) {
            translate([-boxWidth+materialThickness*2,-boxLength+boltPadding,0]) {
                BoltSilhouetteCutout(dimensions);
            }
        }
    }
}

module Teeth(dimensions, laserMargin)
{
    union() {
        translate([-materialThickness,0,0]) {
            TeethRow(dimensions, laserMargin);
        }
        translate([boxWidth-materialThickness*2,0,0]) {
            TeethRow(dimensions, laserMargin);
        }
    }
}

module TeethRow(dimensions, laserMargin)
{
    // centering the teeth row
    teethRowLength = numberOfTeeth*(teethWidth+teethSpacing)-teethSpacing;

    echo(str("teeth row length: ",teethRowLength,"mm"));
    teethRowMargin = boxLength-teethRowLength;
    translate([0,teethRowMargin/2,0]) {
        union() {
            if(numberOfTeeth > 0) {
                for(i = [0: numberOfTeeth-1]) {
                    translate([0,i*(teethWidth+teethSpacing),0]) {
                        Tooth(dimensions,laserMargin);
                    }
                }
            }
        }
    }
}

module Tooth(dimensions,laserMargin) {
    translate([-laserMargin,-laserMargin,0]) {
        if(dimensions == "3D") {
            cube([materialThickness+laserMargin*2,teethWidth+laserMargin*2,materialThickness]);
        } else if(dimensions == "2D") {
            square([materialThickness+laserMargin*2, teethWidth+laserMargin*2]);
        }
    }
}

module BottomPlate(dimensions)
{   difference() {
        if(dimensions == "3D") {
            union() {
                cube([boxWidth-materialThickness*2,
                    boxLength,
                    materialThickness]);
                Teeth(dimensions,0);
            }
        } else if(dimensions == "2D") {
            union() {
                square([boxWidth-materialThickness*2,boxLength]);
                Teeth(dimensions,0);
            }
        }
        // Bolt cutouts
        CornerBoltCutouts(dimensions);
    }
}

module HolderPlate(tubeR,tubeP,teethWidth, iTubes,jTubes, connectionPadding, dimensions)
{

    difference() {
        union() {
            if(dimensions == "3D") {
                cube([boxWidth-materialThickness*2,boxLength,materialThickness]);
            } else if(dimensions == "2D") {
                square([boxWidth-materialThickness*2,boxLength]);
            }
            Teeth(dimensions,0);
        }
        union() {
            for (i = [1:iTubes]) {
                translate([tubeR+tubeP+connectionPadding-materialThickness,
                    i*(tubeR*2+tubeP)-tubeR+connectionPadding,
                    0])
                {
                    for(j = [1:jTubes]) {
                        translate([j*(tubeR*2+tubeP)-tubeR*2-tubeP,0,0]) {
                            if(dimensions == "3D") {
                                cylinder(materialThickness+20,tubeR,tubeR, $fn=100);
                            } else if(dimensions == "2D") {
                                circle(tubeR, $fn=100);
                            }
                        }
                    }
                }
            }
            CornerBoltCutouts(dimensions);
        }
    }
}

module SideWall(teethWidth, connectionPadding, dimensions)
{
    difference() {
        if(dimensions == "3D") {
            cube([boxHeight,boxLength,materialThickness]);
        } else if(dimensions == "2D") {
            square([boxHeight,boxLength]);
        }
        union() {
            translate([boltDiameter*2,0,0]) {
                TeethRow(dimensions, laserCutLaserMargin);
                translate([0,connectionPadding+boltDiameter,0]) {
                    boltHole(dimensions);
                }
                translate([0,boxLength-(connectionPadding+boltDiameter),0]) {
                    boltHole(dimensions);
                }
            }
            translate([bottomHolderZPosition,0,0]) {
                TeethRow(dimensions, laserCutLaserMargin);
            }
            translate([boxHeight-boltDiameter*2,0,0]) {
                TeethRow(dimensions, laserCutLaserMargin);
                translate([0,connectionPadding+boltDiameter,0]) {
                    boltHole(dimensions);
                }
                translate([0,boxLength-(connectionPadding+boltDiameter),0]) {
                    boltHole(dimensions);
                }
            }
            if(boxLength > handHolderSize*1.5) {
                holderMargin = boxLength-handHolderSize;
                translate([boxHeight/1.5,holderMargin/2,0]) {
                    if(dimensions == "3D") {
                        cylinder(
                            materialThickness,
                            handHolderHeight/2,
                            handHolderHeight/2, $fn=100);
                    } else if(dimensions =="2D") {
                        circle(handHolderHeight/2,$fn=100);
                    }
                    translate([-handHolderHeight/2,0,0]) {
                        if(dimensions =="3D") {
                            cube([handHolderHeight,
                                handHolderSize,
                                materialThickness]);
                        } else if(dimensions == "2D") {
                            square([handHolderHeight,handHolderSize]);
                        }
                    }
                    translate([0,handHolderSize,0]) {
                        if(dimensions == "3D") {
                            cylinder(
                                materialThickness,
                                handHolderHeight/2,
                                handHolderHeight/2, $fn=100);
                        } else if(dimensions =="2D") {
                            circle(handHolderHeight/2,$fn=100);
                        }
                    }
                }
            }
        }
    }
}

module boltHole(dimensions) {
    if(dimensions == "3D") {
        translate([boltDiameter/2,0,0]) {
            cylinder(materialThickness,boltDiameter/2,boltDiameter/2, $fn=100);
        }
    } else if (dimensions == "2D") {
        translate([boltDiameter/2,0,0]) {
            circle(boltDiameter/2, $fn=100);
        }
    }
}


module boxAsFlatFile(dimensions) {
    moduleDimensions = dimensions;
    BottomPlate(moduleDimensions);

    translate([boxWidth+laserCutPieceSpacing,0,0]) {
        HolderPlate(
            tubeRadius,
            tubePadding,
            teethWidth,
            iTubes,
            jTubes,
            connectionPadding,
            moduleDimensions);

        translate([boxWidth+laserCutPieceSpacing+connectionPadding,0,0]) {
            HolderPlate(
                tubeRadius,
                tubePadding,
                teethWidth,
                iTubes,
                jTubes,
                connectionPadding,
                moduleDimensions);

            translate([boxWidth+laserCutPieceSpacing+connectionPadding,0,0]) {
                SideWall(
                    teethWidth,
                    connectionPadding,
                    moduleDimensions);
                translate([boxHeight+laserCutPieceSpacing,0,0]) {
                    SideWall(
                        teethWidth,
                        connectionPadding,
                        moduleDimensions);
                }
            }
        }
    }
}

module boxIn3D(dimensions,expanded) {
    moduleDimensions = dimensions;
    translate([materialThickness,0,boltDiameter*2]) {
        BottomPlate(moduleDimensions);
    }
    translate([materialThickness,0,bottomHolderZPosition]) {
        HolderPlate(
            tubeRadius,
            tubePadding,
            teethWidth,
            iTubes,
            jTubes,
            connectionPadding,
            moduleDimensions);
    }

    translate([materialThickness,0,holderHeight-boltDiameter*2]) {
        HolderPlate(
            tubeRadius,
            tubePadding,
            teethWidth,
            iTubes,
            jTubes,
            connectionPadding,
            moduleDimensions);
    }
    translate([materialThickness-expanded,0,0]) {
        rotate([0,-90,0]) {
            SideWall(
                teethWidth,
                connectionPadding,
                moduleDimensions);
        }
    }
    translate([boxWidth+expanded,0,0]) {
        rotate([0,-90,0])
            {
            SideWall(
                teethWidth,
                connectionPadding,
                moduleDimensions);
        }
    }
}

scale([1,1,1]) {

boxAsFlatFile("2D");

translate([0,-boxLength-100,0]) {
    boxIn3D("3D",0);
}

translate([0,-boxLength*2-150,0]) {
    boxIn3D("3D",20);
}

}
