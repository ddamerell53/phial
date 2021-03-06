package phylo;

/*
* PHIAL (Phylogenetic interactve annotation library)
* Written in 2018 by
*   David Damerell <david.damerell@sgc.ox.ac.uk>, Leonidas Koukouflis <leonidas.koukouflis@sgc.ox.ac.uk>,
*   Lihua Liu <liulihua1@gmail.com> Sefa Garsot <>
*   Brian Marsden <brian.marsden@sgc.ox.ac.uk> Matthieu Schapira <matthieu.schapira@utoronto.ca>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

import phylo.PhyloTreeNode.LineMode;

@:keep
class PhyloRadialTreeLayout{

    public var cx: Float;
    public var cy: Float;

    var annotations:Array<PhyloAnnotation>;

    public function new (width: Float, height: Float){
        this.cx=width/2;
        this.cy=height/2;

    }

    @:keep
    public function renderCircle (treeNode: PhyloTreeNode, renderer: PhyloCanvasRenderer, annotations:Dynamic, annotList:Array<PhyloAnnotation>, lineColour = "rgb(28,102,224)"){
        if(treeNode.colour != null){
            lineColour = treeNode.colour;
        }

        _renderCircle(treeNode,renderer, annotations, annotList, lineColour, lineColour);
    }

    @:keep
    function _renderCircle(treeNode: PhyloTreeNode, renderer: PhyloCanvasRenderer, annotations:Dynamic, annotList:Array<PhyloAnnotation>, lineColour = "rgb(28,102,224)", parentColour="rgb(28,102,224)") {
        var blue = 'rgb(41,128,214)';
        var red = 'rgb(255,0,0)';
        var black = 'rgb(68,68,68)';

        if(treeNode.parent == null){
            //renderer.ctx.translate(renderer.cx,renderer.cy);
        }

        treeNode.space = 0;

        var cx = renderer.cx;
        var cy = renderer.cy;

        var textSize = null;

        var branch = (cx * 2 / treeNode.root.getHeight()) / (4 - (treeNode.root.getHeight() * 0.011));
        var k = 2 * Math.PI / treeNode.root.getLeafCount();

        var fontW = 12;
        var fontH = 12;

        var firstChild = treeNode.children[0];
        var lastChild = treeNode.children[treeNode.children.length-1];

        var i : Float = treeNode.angle;

        for(child in treeNode.children){
            var childLineColour = lineColour;
            if(child.colour != null){
                childLineColour = child.colour;
            }

            i = _renderCircle(child, renderer, annotations, annotList, childLineColour, lineColour);
        }

        var h  :Float = null;
        var ph  :Float = null;
        var angle :Float = null;

        var y1 :Float, y2 :Float= null;
        var x1 :Float , x2 :Float= null;

        if(treeNode.parent != null){
            h = branch * (treeNode.root.getHeight() - treeNode.getHeight());
            ph = branch * (treeNode.root.getHeight() - treeNode.parent.getHeight());

            if(treeNode.wedgeColour != null){
                var startNode = null;
                var endNode = null;

                if(!treeNode.isLeaf()){
                    startNode = treeNode.findLastLeaf();
                    endNode = treeNode.findFirstLeaf();
                }else{
                    startNode = treeNode.parent.findLastLeaf();
                    endNode = treeNode.parent.findFirstLeaf();
                }

                var wedgeH=treeNode.root.getHeight() * ((cx * 2 / treeNode.root.getHeight()) / (4 - (treeNode.root.getHeight() * 0.011)));

                renderer.drawWedge(0, 0, wedgeH ,  endNode.angle, startNode.angle, treeNode.wedgeColour ,1);
            }

            if(treeNode.isLeaf()){
                angle = i;
            }else{
                angle = (lastChild.angle - firstChild.angle) / 2 + firstChild.angle;

                if(Math.abs(PhyloHubMath.radiansToDegrees(lastChild.angle - firstChild.angle)) < 10) {
                    renderer.drawLine(firstChild.x, firstChild.y, lastChild.x, lastChild.y, lineColour, firstChild.lineWidth);

                    //renderer.drawWedge(0, 0, h  , firstChild.angle, lastChild.angle, lineColour, treeNode.lineWidth);
                }else{
                    renderer.drawArc(0, 0, h , firstChild.angle, lastChild.angle, lineColour, treeNode.lineWidth);


                    //renderer.drawWedge(0, 0, h , firstChild.angle, lastChild.angle, lineColour, treeNode.lineWidth);
                }
            }

            treeNode.angle = angle;
            if(angle == 0){
                y1 = 0;	y2 = 0;
            }else{
                y1 = h * Math.sin(angle);
                y2 = ph * Math.sin(angle);
            }

            x1 = h * Math.cos(angle);	x2 = ph * Math.cos(angle);

            treeNode.x = x2;
            treeNode.y =  y2;

            /*var lineColour = blue;

            if(treeNode.parent == treeNode.root){
                lineColour = blue;
            }*/

            // Inner branch lines
            renderer.drawLine(x1, y1, x2, y2, lineColour, treeNode.lineWidth);

            if(treeNode.isLeaf()){
                var dy = y1-y2;
                var dx = x1-x2;

                var x = 0;
                var y = 0;

                var gap = 2;

                var ta;
                // Avoid upside down labels
                if(dx < 0){
                    ta = Math.atan2(dy,dx) - Math.PI;
                    x = - renderer.mesureText(treeNode.name) - gap;
                }else{
                    ta = Math.atan2(dy,dx);

                    x = gap;
                }

                y = 3;

                var labelColour = black;

                if(renderer.getConfig().highlightedGenes.exists(treeNode.name)==true){
                    labelColour = 'red';
                }

                renderer.drawTextNoTranslate(treeNode.name,x2 + dx ,y2+ dy , x,y,ta,'top',labelColour);

                i += k;

                var t= treeNode.root.getMaximumLeafNameLength(renderer) + 10; // calculate the width of the text in pixels and we add padding

                treeNode.rad = ta;

                treeNode.x = x1;
                treeNode.y =  y1;
                //treeNode.quad = 9;

                renderer.ctx.save();
                //renderer.ctx.translate(x2 + dx,y2+ dy );
                //renderer.ctx.rotate(ta);

                //renderer.ctx.setTransform(1, 0, 0, 1, 0, 0);


                if((treeNode.y>y2) && (treeNode.x > x2)) {
                    treeNode.quad=1;
                }
                if((treeNode.y<y2) && (treeNode.x > x2)){
                    treeNode.quad=2;
                }
                if((treeNode.y<y2) && (treeNode.x < x2)){
                    treeNode.quad=3;
                }
                if((treeNode.y>y2) && (treeNode.x < x2)){
                    treeNode.quad=4;
                }
                if((treeNode.y==y2) && (treeNode.x > x2)){
                    treeNode.quad=5;
                }
                if((treeNode.y==y2) && (treeNode.x < x2)){
                    treeNode.quad=6;
                }
                if((treeNode.y>y2) && (treeNode.x == x2)){
                    treeNode.quad=7;
                }
                if((treeNode.y<y2) && (treeNode.x == x2)){
                    treeNode.quad=8;
                }

                var j:Int;
                for( j in 1...annotations.length ) {
                    if(annotations[j]==true){
                        var added:Bool;
                        added=addAnnotation(treeNode,j, t, renderer,annotList);

                        if((treeNode.annotations[j]!=null)&&(treeNode.annotations[j].alfaAnnot[0]!=null)&&(treeNode.annotations[j].alfaAnnot.length>0)){
                            var u=0;
                            if(added==true)treeNode.space=treeNode.space-1;
                            treeNode.space=treeNode.space+1;
                            for (u in 0...treeNode.annotations[j].alfaAnnot.length){
                                if(annotList[j].shape=='text' && treeNode.quad==2) treeNode.space=treeNode.space+2;
                                else if(annotList[j].shape=='text' && treeNode.quad==1) treeNode.space=treeNode.space+2;
                                else treeNode.space=treeNode.space+1;
                                added=addAlfaAnnotation(treeNode,treeNode.annotations[j].alfaAnnot[u],j, t, renderer,annotList);

                            }if(added==true){
                                treeNode.space=treeNode.space+1;
                            }
                        }else  if(added==true)treeNode.space=treeNode.space+1;
                    }
                }

                renderer.ctx.restore();

                treeNode.x = x2 ;
                treeNode.y =  y2;
            }


        }

        for(child in treeNode.children){
            var data:PhyloScreenData;
            data=new PhyloScreenData();

            data.renderer=renderer;
            data.isAnnot=false;
            data.nodeId=child.nodeId;
            data.point=5;
            data.width=10;
            data.height=10;

            data.parentx=Math.round(treeNode.x);
            data.parenty=Math.round(treeNode.y);

            data.x=Math.round(child.x);
            data.y=Math.round(child.y);
            treeNode.root.screen[treeNode.root.screen.length]=data;
        }

        if(treeNode.parent == null){
            var rootScreen = new PhyloScreenData();
            rootScreen.x = treeNode.x;
            rootScreen.y = treeNode.y;
            rootScreen.nodeId = treeNode.nodeId;
            rootScreen.renderer = renderer;

            rootScreen.point=5;
            rootScreen.width=10;
            rootScreen.height=10;

            treeNode.screen.push(rootScreen);
        }

        return i;
    }

    public function render (treeNode: PhyloTreeNode, renderer: PhyloCanvasRenderer, annotations:Dynamic, annotList:Array<PhyloAnnotation>, lineColour = "rgb(28,102,224)"){
        var i=0;
        var x=treeNode.x;
        var y=treeNode.y;

        if(renderer.getConfig().editmode==true) lineColour="rgb(234,147,28)";

        while(i<treeNode.children.length){
            treeNode.children[i].space=0;

            if(treeNode.children[i].isLeaf()) {
                //renderer.drawLine(x,y,treeNode.children[i].x,treeNode.children[i].y,lineColour);

                if(treeNode.children[i].lineMode == LineMode.BEZIER){
                    var deltaX = Math.abs(x - treeNode.children[i].x);
                    var deltaY =  Math.abs(y - treeNode.children[i].y);

                    var firstY, secondY;
                    var firstX, secondX;

                    if(treeNode.children[i].xRandom == null){
                        treeNode.children[i].xRandom = Math.random() * (0.6-0.3) + 0.3;
                    }

                    if(treeNode.children[i].yRandom == null){
                        treeNode.children[i].yRandom = Math.random() * (0.8-0.4) + 0.4;
                    }

                    if(treeNode.children[i].y < y){
                        firstY = y -(deltaY * treeNode.children[i].yRandom);
                        secondY = treeNode.children[i].y +(deltaY * treeNode.children[i].yRandom);
                    }else{
                        firstY = y +(deltaY * treeNode.children[i].yRandom);
                        secondY = treeNode.children[i].y -(deltaY * treeNode.children[i].yRandom);
                    }

                    if(treeNode.children[i].x > x){
                        firstX = x + (deltaX * 0.6);
                        secondX = treeNode.children[i].x -(deltaX * treeNode.children[i].xRandom);
                    }else{
                        firstX = x - (deltaX * 0.6);
                        secondX = treeNode.children[i].x +(deltaX * treeNode.children[i].xRandom);
                    }

                    renderer.bezierCurve(x,y,treeNode.children[i].x,treeNode.children[i].y,firstX, firstY, secondX, secondY, lineColour, treeNode.children[i].lineWidth);
                }else{
                    renderer.drawLine(x,y,treeNode.children[i].x,treeNode.children[i].y,lineColour, treeNode.children[i].lineWidth);
                }

                var t:Int;
                var aux,aux1;
                var yequalsign=false;
                if((treeNode.children[i].y>0)&&(y>0)) yequalsign=true;
                else if((treeNode.children[i].y<0)&&(y<0)) yequalsign=true;
                var xequalsign=false;
                if((treeNode.children[i].x>0)&&(x>0)) xequalsign=true;
                else if((treeNode.children[i].x<0)&&(x<0)) xequalsign=true;

                var deltaY,deltaX:Dynamic;
                if(xequalsign==true) deltaX=Math.abs(treeNode.children[i].x-x);
                else deltaX=Math.abs(treeNode.children[i].x)+Math.abs(x);
                if(yequalsign==true) deltaY=Math.abs(treeNode.children[i].y-y);
                else deltaY=Math.abs(treeNode.children[i].y)+Math.abs(y);


                var tang=deltaY/deltaX;
                treeNode.children[i].rad = Math.atan(tang); // In radians
                var rot:Float;

                rot=0;
                var orign='start';

                if((treeNode.children[i].y>y) && (treeNode.children[i].x > x)) {
                    rot=treeNode.children[i].rad;
                    orign="start";
                    treeNode.children[i].quad=1;
                }
                if((treeNode.children[i].y<y) && (treeNode.children[i].x > x)){
                    rot=2*Math.PI-treeNode.children[i].rad;
                    orign="start";
                    treeNode.children[i].quad=2;
                }
                if((treeNode.children[i].y<y) && (treeNode.children[i].x < x)){
                    rot=treeNode.children[i].rad;
                    orign="end";
                    treeNode.children[i].quad=3;
                }
                if((treeNode.children[i].y>y) && (treeNode.children[i].x < x)){
                    rot=(2*Math.PI)-treeNode.children[i].rad;
                    orign="end";
                    treeNode.children[i].quad=4;
                }
                if((treeNode.children[i].y==y) && (treeNode.children[i].x > x)){
                    treeNode.children[i].quad=5;
                    rot=0;
                }
                if((treeNode.children[i].y==y) && (treeNode.children[i].x < x)){
                    treeNode.children[i].quad=6;
                    rot=Math.PI;
                }
                if((treeNode.children[i].y>y) && (treeNode.children[i].x == x)){
                    rot=3*Math.PI-(Math.PI/2);
                    treeNode.children[i].quad=7;
                }
                if((treeNode.children[i].y<y) && (treeNode.children[i].x == x)){
                    treeNode.children[i].quad=8;
                    rot=3*Math.PI/4;
                }

                //here we write the target name
                //if the target is in  highlightedGene list, we must write its name using red color
                var namecolor='#585b5f';
                var ttar=treeNode.children[i].name;
                if(renderer.getConfig().highlightedGenes.exists(ttar)==true) namecolor='#ff0000';

                //rot = rot + (rot/100)* 5 ;

                renderer.drawText(' '+treeNode.children[i].name, treeNode.children[i].x,treeNode.children[i].y, -2, 3,rot,orign,namecolor);
                updateTreeRectangle(treeNode.children[i].x,treeNode.children[i].y, treeNode.root);
                t= renderer.mesureText(treeNode.children[i].name)+10; // calculate the width of the text in pixels and we add padding
                treeNode.children[i].rad=rot;

                var j:Int;
                for( j in 1...annotations.length ) {

                    if(annotations[j]==true){
                        var added:Bool;
                        added=addAnnotation(treeNode.children[i],j, t, renderer,annotList);

                        if((treeNode.children[i].annotations[j]!=null)&&(treeNode.children[i].annotations[j].alfaAnnot[0]!=null)&&(treeNode.children[i].annotations[j].alfaAnnot.length>0)){
                            var u=0;
                            if(added==true)treeNode.children[i].space=treeNode.children[i].space-1;
                            treeNode.children[i].space=treeNode.children[i].space+1;
                            for (u in 0...treeNode.children[i].annotations[j].alfaAnnot.length){
                                if(annotList[j].shape=='text' && treeNode.children[i].quad==2) treeNode.children[i].space=treeNode.children[i].space+2;
                                else if(annotList[j].shape=='text' && treeNode.children[i].quad==1) treeNode.children[i].space=treeNode.children[i].space+2;
                                else treeNode.children[i].space=treeNode.children[i].space+1;
                                added=addAlfaAnnotation(treeNode.children[i],treeNode.children[i].annotations[j].alfaAnnot[u],j, t, renderer,annotList);

                            }if(added==true){
                                treeNode.children[i].space=treeNode.children[i].space+1;
                            }
                        }else  if(added==true)treeNode.children[i].space=treeNode.children[i].space+1;
                    }
                }
            }
            else{
                var childLineColour = lineColour;
                if(treeNode.children[i].colour != null){
                    childLineColour = treeNode.children[i].colour;
                }

                this.render(treeNode.children[i],renderer, annotations,annotList,childLineColour); //the edge here is already drawn

                if(treeNode.children[i].lineMode == LineMode.BEZIER){
                    var deltaX = Math.abs(x - treeNode.children[i].x);
                    var deltaY =  Math.abs(y - treeNode.children[i].y);

                    var firstY, secondY;
                    var firstX, secondX;

                    if(treeNode.children[i].xRandom == null){
                        treeNode.children[i].xRandom = Math.random() * (0.6-0.3) + 0.3;
                    }

                    if(treeNode.children[i].yRandom == null){
                        treeNode.children[i].yRandom = Math.random() * (0.8-0.4) + 0.4;
                    }

                    if(treeNode.children[i].y < y){
                        firstY = y -(deltaY * treeNode.children[i].yRandom);
                        secondY = treeNode.children[i].y +(deltaY * treeNode.children[i].yRandom);
                    }else{
                        firstY = y +(deltaY * treeNode.children[i].yRandom);
                        secondY = treeNode.children[i].y -(deltaY * treeNode.children[i].yRandom);
                    }

                    if(treeNode.children[i].x > x){
                        firstX = x + (deltaX * 0.6);
                        secondX = treeNode.children[i].x -(deltaX * treeNode.children[i].xRandom);
                    }else{
                        firstX = x - (deltaX * 0.6);
                        secondX = treeNode.children[i].x +(deltaX * treeNode.children[i].xRandom);
                    }

                    renderer.bezierCurve(x,y,treeNode.children[i].x,treeNode.children[i].y,firstX, firstY, secondX, secondY, lineColour, treeNode.children[i].lineWidth);
                }else{
                    renderer.drawLine(x,y,treeNode.children[i].x,treeNode.children[i].y,lineColour, treeNode.children[i].lineWidth);
                }

                var data:PhyloScreenData;
                data=new PhyloScreenData();

                data.renderer=renderer;
                data.isAnnot=false;
                data.nodeId=treeNode.children[i].nodeId;
                data.point=5;
                data.width=10;
                data.height=10;

                data.parentx=Math.round(x);
                data.parenty=Math.round(y);

                data.x=Math.round(treeNode.children[i].x);
                data.y=Math.round(treeNode.children[i].y);
                treeNode.root.screen[treeNode.root.screen.length]=data;
            }
            i++;

        }

        if(treeNode.parent == null){
            var rootScreen = new PhyloScreenData();
            rootScreen.x = treeNode.x;
            rootScreen.y = treeNode.y;
            rootScreen.nodeId = treeNode.nodeId;
            rootScreen.renderer = renderer;

            rootScreen.point=5;
            rootScreen.width=10;
            rootScreen.height=10;

            treeNode.screen.push(rootScreen);
        }

    }

    public function addAnnotation(leave:PhyloTreeNode, annotation:Int, long: Int, renderer: PhyloCanvasRenderer, annotList:Array<PhyloAnnotation>):Bool{

        if(annotList[annotation].optionSelected.length!=0){
            if(leave.annotations[annotation]!=null){
                if(annotList[annotation].optionSelected[0]!=leave.annotations[annotation].option){
//it means this node has the annotation for another suboption, not the current one
                    return false;
                }
            }
        }

        var res:Bool=false;
        var data:PhyloScreenData;
        data=new PhyloScreenData();

        data.renderer=renderer;
        data.target=leave.name;
        data.isAnnot=true;
        var name:String;
        name='';
        if(leave.name.indexOf('(')!=-1 || leave.name.indexOf('-')!=-1){
            var auxArray=leave.name.split('');
            var j:Int;
            for(j in 0...auxArray.length){
                if (auxArray[j]=='(' || auxArray[j]=='-') break;
                name+=auxArray[j];

            }
            data.targetClean=name;

        }else{
//name==target
            data.targetClean=leave.name;
        }


        data.annot=annotation;

        data.annotation=leave.annotations[annotation];

        var nx,ny:Dynamic;
        nx=0.0;ny=0.0;
//data.suboption=leave.annotations[annotation].option;
        if(leave.space==0) long=long+1;
//we need to check if the leave has this annotation
        var rootN=leave.root;
        switch annotList[annotation].shape {
            case "cercle":
                if(leave.activeAnnotation[annotation]==true){
                    if(leave.annotations[annotation].hasAnnot==true){
                        switch(leave.quad){
                            case 1:
                                long=long+(23*leave.space);
                                nx=leave.x+Math.cos(leave.rad)*(long+3);
                                ny=leave.y+Math.sin(leave.rad)*(long+3);
                            case 2:
                                long=long+(20*leave.space);
                                nx=leave.x+Math.cos(leave.rad)*(long+3);
                                ny=leave.y+Math.sin(leave.rad)*(long+3);
                            case 3:
                                long=long+(23*leave.space);
                                ny=leave.y-Math.sin(leave.rad)*(long+3);
                                nx=leave.x-Math.cos(leave.rad)*(long+3);
                            case 4:
                                long=long+(20*leave.space);
                                ny=leave.y-Math.sin(leave.rad)*(long+3);
                                nx=leave.x-Math.cos(leave.rad)*(long+3);
                            case 5:
                                long=long+(20*leave.space);
                                ny=leave.y;
                                nx=leave.x+Math.cos(leave.rad)*long;
                            case 6: ny=leave.y;
                                long=long+(20*leave.space);
                                nx=leave.x-Math.cos(leave.rad)*long;
                            case 7: nx=leave.x;
                                long=long+(20*leave.space);
                                ny=leave.y+Math.sin(leave.rad)*long;
                            case 8: nx=leave.x;
                                long=long+(20*leave.space);
                                ny=leave.y-Math.sin(leave.rad)*long;

                        }
                        if(leave.space==0) long=long+1;
                        renderer.drawCircle(nx,ny,leave.annotations[annotation].color[0].color);
                        //if(leave.annotations[annotation].text!=''){
                        //    renderer.drawText(leave.annotations[annotation].text,nx,ny, -2, 3,0,"start",'#000000');
                        //}

                        data.x=Math.round(nx);
                        data.y=Math.round(ny);
                        data.width=14;
                        data.height=14;
                        data.point=3;
                        res=true;
                    }
                    else return false;
                }
            case "image":
                if(leave.activeAnnotation[annotation]==true){
                    if(leave.annotations[annotation].hasAnnot==true){
                        if(annotList[annotation].annotImg[leave.annotations[annotation].defaultImg]!=null){

                            switch(leave.quad){
                                case 1: long=long+(20*leave.space);
                                    nx=leave.x+Math.cos(leave.rad)*long;
                                    ny=leave.y+Math.sin(leave.rad)*long;
                                case 2: long=long+(20*leave.space);
                                    nx=leave.x-5+Math.cos(leave.rad)*(long);
                                    ny=leave.y-12+Math.sin(leave.rad)*long;
                                case 3: long=long+(23*leave.space);
                                    ny=leave.y-12-Math.sin(leave.rad)*long;
                                    nx=leave.x-10-Math.cos(leave.rad)*long;
                                case 4: long=long+(23*leave.space);
                                    ny=leave.y-Math.sin(leave.rad)*(long);
                                    nx=leave.x-10-Math.cos(leave.rad)*long;
                                case 5: long=long+(20*leave.space);
                                    ny=leave.y;
                                    nx=leave.x+Math.cos(leave.rad)*long;
                                case 6: long=long+(20*leave.space);
                                    ny=leave.y;
                                    nx=leave.x-Math.cos(leave.rad)*long;
                                case 7: long=long+(20*leave.space);
                                    nx=leave.x;
                                    ny=leave.y+Math.sin(leave.rad)*long;
                                case 8: long=long+(20*leave.space);
                                    nx=leave.x;
                                    ny=leave.y-Math.sin(leave.rad)*long;

                            }
                            if(leave.space==0) long=long+1;
                            var imge=annotList[annotation].annotImg[leave.annotations[annotation].defaultImg];
                            if (imge!=null) {
                                if(annotation==1) renderer.drawImg(nx,ny,imge,1);
                                else renderer.drawImg(nx,ny,imge,0);
                                data.x=Math.round(nx);
                                data.y=Math.round(ny);
                                data.width=14;
                                data.height=14;
                                data.point=1;
                            }

                        }
                        res=true;
                    }
                    else return false;

                }
            case "square":
                if(leave.activeAnnotation[annotation]==true){
                    if(leave.annotations[annotation].hasAnnot==true){

                        switch(leave.quad){
                            case 1:
                                long=long+(23*leave.space);
                                nx=leave.x+Math.cos(leave.rad)*long;
                                ny=leave.y+Math.sin(leave.rad)*long;
                            case 2:
                                long=long+(20*leave.space);
                                nx=leave.x+Math.cos(leave.rad)*long;
                                ny=leave.y-12+Math.sin(leave.rad)*long;
                            case 3:
                                long=long+(23*leave.space);
                                ny=leave.y-12-Math.sin(leave.rad)*long;
                                nx=leave.x-10-Math.cos(leave.rad)*long;
                            case 4:
                                long=long+(20*leave.space);
                                ny=leave.y-Math.sin(leave.rad)*long;
                                nx=leave.x-Math.cos(leave.rad)*long;
                            case 5:
                                long=long+(20*leave.space);
                                ny=leave.y;
                                nx=leave.x+Math.cos(leave.rad)*long;
                            case 6:
                                long=long+(20*leave.space);
                                ny=leave.y;
                                nx=leave.x-Math.cos(leave.rad)*long;
                            case 7: nx=leave.x;
                                long=long+(20*leave.space);
                                ny=leave.y+Math.sin(leave.rad)*long;
                            case 8: nx=leave.x;
                                long=long+(20*leave.space);
                                ny=leave.y-Math.sin(leave.rad)*long;

                        }
                        if(leave.space==0) long=long+1;
                        renderer.drawSquare(nx,ny,leave.annotations[annotation].color[0].color);

                        data.x=Math.round(nx);
                        data.y=Math.round(ny);
                        data.width=14;
                        data.height=10;
                        data.point=4;
                        res=true;

                    }
                    else return false;
                }
            case "html":
                if(leave.activeAnnotation[annotation]==true){
                    if(leave.annotations[annotation].hasAnnot==true){

                        switch(leave.quad){
                            case 1:
                                long=long+(23*leave.space);
                                nx=leave.x+Math.cos(leave.rad)*long;
                                ny=leave.y+Math.sin(leave.rad)*long;
                            case 2:
                                long=long+(20*leave.space);
                                nx=leave.x+Math.cos(leave.rad)*long;
                                ny=leave.y-12+Math.sin(leave.rad)*long;
                            case 3:
                                long=long+(23*leave.space);
                                ny=leave.y-12-Math.sin(leave.rad)*long;
                                nx=leave.x-10-Math.cos(leave.rad)*long;
                            case 4:
                                long=long+(20*leave.space);
                                ny=leave.y-Math.sin(leave.rad)*long;
                                nx=leave.x-Math.cos(leave.rad)*long;
                            case 5:
                                long=long+(20*leave.space);
                                ny=leave.y;
                                nx=leave.x+Math.cos(leave.rad)*long;
                            case 6:
                                long=long+(20*leave.space);
                                ny=leave.y;
                                nx=leave.x-Math.cos(leave.rad)*long;
                            case 7: nx=leave.x;
                                long=long+(20*leave.space);
                                ny=leave.y+Math.sin(leave.rad)*long;
                            case 8: nx=leave.x;
                                long=long+(20*leave.space);
                                ny=leave.y-Math.sin(leave.rad)*long;

                        }
                        if(leave.space==0) long=long+1;

                        renderer.drawGraphic(nx,ny,leave.results);

                        data.x=Math.round(nx);
                        data.y=Math.round(ny);
                        data.width=14;
                        data.height=10;
                        data.point=4;
                        res=true;

                    }
                    else return false;
                }
            case "text":
                if(leave.activeAnnotation[annotation]==true){
                    if(leave.annotations[annotation].hasAnnot==true){

                        switch(leave.quad){
                            case 1: long=long+(20*leave.space);
                                nx=leave.x+Math.cos(leave.rad)*(long+10);
                                ny=leave.y+Math.sin(leave.rad)*(long+10);
                            case 2: long=long+(20*leave.space);
                                nx=leave.x+Math.cos(leave.rad)*(long+10);
                                ny=leave.y+Math.sin(leave.rad)*(long+10);
                            case 3: long=long+(23*leave.space);
                                ny=leave.y-Math.sin(leave.rad)*(long+10);
                                nx=leave.x-Math.cos(leave.rad)*(long+10);
                            case 4: long=long+(23*leave.space);
                                ny=leave.y-Math.sin(leave.rad)*(long+10);
                                nx=leave.x-Math.cos(leave.rad)*(long+10);
                            case 5: long=long+(20*leave.space);
                                ny=leave.y;
                                nx=leave.x+Math.cos(leave.rad)*(long+10);
                            case 6: long=long+(20*leave.space);
                                ny=leave.y;
                                nx=leave.x-Math.cos(leave.rad)*(long+10);
                            case 7: long=long+(20*leave.space);
                                nx=leave.x;
                                ny=leave.y+Math.sin(leave.rad)*(long+10);
                            case 8: long=long+(20*leave.space);
                                nx=leave.x;
                                ny=leave.y-Math.sin(leave.rad)*(long+5);

                        }
                        renderer.drawText(leave.annotations[annotation].text,nx,ny, -2, 3,0,"start",leave.annotations[annotation].color[0].color);

                        data.x=Math.round(nx);
                        data.y=Math.round(ny);
                        data.width=7*leave.annotations[annotation].text.length;
                        data.height=7;
                        data.point=2;
                        res=true;

                    }
                    else return false;
                }
        }

        leave.root.screen[leave.root.screen.length]=data;
        return res;
    }


    public function addAlfaAnnotation(leave:PhyloTreeNode, alfaAnnot:PhyloAnnotation, annotation:Int, long: Int, renderer: PhyloCanvasRenderer, annotList:Array<PhyloAnnotation>):Bool{
        var res:Bool=false;
        var data:PhyloScreenData;
        var nx,ny:Dynamic;
        nx=0.0;ny=0.0;
        data=new PhyloScreenData();

        data.renderer=renderer;
        data.target=leave.name;
        data.isAnnot=true;
        var name:String;
        name='';
        if(leave.name.indexOf('(')!=-1 || leave.name.indexOf('-')!=-1){
            var auxArray=leave.name.split('');
            var j:Int;
            for(j in 0...auxArray.length){
                if (auxArray[j]=='(' || auxArray[j]=='-') break;
                name+=auxArray[j];

            }
            data.targetClean=name;

        }else{
//name==target
            data.targetClean=leave.name;
        }

        data.annot=annotation;

        data.annotation=alfaAnnot;
        data.suboption=alfaAnnot.option;


//we need to check if the leave has this annotation

        switch annotList[annotation].shape {
            case "cercle":
                if(leave.activeAnnotation[annotation]==true){
                    if(alfaAnnot.hasAnnot==true){
                        switch(leave.quad){
                            case 1:
                                long=long+(23*leave.space);
                                nx=leave.x+Math.cos(leave.rad)*(long+3);
                                ny=leave.y+Math.sin(leave.rad)*(long+3);
                            case 2:
                                long=long+(20*leave.space);
                                nx=leave.x+Math.cos(leave.rad)*(long+3);
                                ny=leave.y+Math.sin(leave.rad)*(long+3);
                            case 3:
                                long=long+(23*leave.space);
                                ny=leave.y-Math.sin(leave.rad)*(long+3);
                                nx=leave.x-Math.cos(leave.rad)*(long+3);
                            case 4:
                                long=long+(20*leave.space);
                                ny=leave.y-Math.sin(leave.rad)*(long+3);
                                nx=leave.x-Math.cos(leave.rad)*(long+3);
                            case 5:
                                long=long+(20*leave.space);
                                ny=leave.y;
                                nx=leave.x+Math.cos(leave.rad)*long;
                            case 6: ny=leave.y;
                                long=long+(20*leave.space);
                                nx=leave.x-Math.cos(leave.rad)*long;
                            case 7: nx=leave.x;
                                long=long+(20*leave.space);
                                ny=leave.y+Math.sin(leave.rad)*long;
                            case 8: nx=leave.x;
                                long=long+(20*leave.space);
                                ny=leave.y-Math.sin(leave.rad)*long;
                            case 9: long = long=long+(20*leave.space);

                        }
                        if(leave.space==0) long=long+1;

                        if(leave.quad == 9){
                            renderer.drawCircle(leave.x + long,leave.y, alfaAnnot.color[0].color);
                        }else{
                            renderer.drawCircle(nx,ny,alfaAnnot.color[0].color);
                        }


                        var aux=nx*renderer.scale;
                        data.x=Math.round(aux)-29;
                        aux=ny*renderer.scale;
                        data.y=Math.round(aux)-3;
                        aux=10*renderer.scale;
                        data.width=Math.round(aux);
                        data.height=Math.round(aux);
                        data.point=4;
                        res=true;
                    }
                    else return false;
                }

            case "image":
                if(leave.activeAnnotation[annotation]==true){
                    if(alfaAnnot.hasAnnot==true){
                        if(annotList[annotation].annotImg[alfaAnnot.defaultImg]!=null){
                            switch(leave.quad){
                                case 1: long=long+(20*leave.space);
                                    nx=leave.x+Math.cos(leave.rad)*long;
                                    ny=leave.y+Math.sin(leave.rad)*long;
                                case 2: long=long+(20*leave.space);
                                    nx=leave.x-5+Math.cos(leave.rad)*(long);
                                    ny=leave.y-12+Math.sin(leave.rad)*long;
                                case 3: long=long+(23*leave.space);
                                    ny=leave.y-12-Math.sin(leave.rad)*long;
                                    nx=leave.x-10-Math.cos(leave.rad)*long;
                                case 4: long=long+(23*leave.space);
                                    ny=leave.y-Math.sin(leave.rad)*(long);
                                    nx=leave.x-10-Math.cos(leave.rad)*long;
                                case 5: long=long+(20*leave.space);
                                    ny=leave.y;
                                    nx=leave.x+Math.cos(leave.rad)*long;
                                case 6: long=long+(20*leave.space);
                                    ny=leave.y;
                                    nx=leave.x-Math.cos(leave.rad)*long;
                                case 7: long=long+(20*leave.space);
                                    nx=leave.x;
                                    ny=leave.y+Math.sin(leave.rad)*long;
                                case 8: long=long+(20*leave.space);
                                    nx=leave.x;
                                    ny=leave.y-Math.sin(leave.rad)*long;

                            }
                            var imge=annotList[annotation].annotImg[alfaAnnot.defaultImg];
                            if (imge!=null) {

                                if(annotation==1) renderer.drawImg(nx,ny,imge,1);
                                else renderer.drawImg(nx,ny,imge,0);

                                var aux=nx*renderer.scale;
                                data.x=Math.round(aux);
                                aux=ny*renderer.scale;
                                data.y=Math.round(aux);

                                aux=14*renderer.scale;
                                data.width=Math.round(aux);
                                aux=14*renderer.scale;
                                data.height=Math.round(aux);
                                data.point=1;
                            }

                        }
                        res=true;
                    }
                    else return false;

                }
            case "square":
                if(leave.activeAnnotation[annotation]==true){
                    if(alfaAnnot.hasAnnot==true){
                        switch(leave.quad){
                            case 1:
                                long=long+(23*leave.space);
                                nx=leave.x+Math.cos(leave.rad)*long;
                                ny=leave.y+Math.sin(leave.rad)*long;
                            case 2:
                                long=long+(20*leave.space);
                                nx=leave.x+Math.cos(leave.rad)*long;
                                ny=leave.y-12+Math.sin(leave.rad)*long;
                            case 3:
                                long=long+(23*leave.space);
                                ny=leave.y-12-Math.sin(leave.rad)*long;
                                nx=leave.x-10-Math.cos(leave.rad)*long;
                            case 4:
                                long=long+(20*leave.space);
                                ny=leave.y-Math.sin(leave.rad)*long;
                                nx=leave.x-Math.cos(leave.rad)*long;
                            case 5:
                                long=long+(20*leave.space);
                                ny=leave.y;
                                nx=leave.x+Math.cos(leave.rad)*long;
                            case 6:
                                long=long+(20*leave.space);
                                ny=leave.y;
                                nx=leave.x-Math.cos(leave.rad)*long;
                            case 7: nx=leave.x;
                                long=long+(20*leave.space);
                                ny=leave.y+Math.sin(leave.rad)*long;
                            case 8: nx=leave.x;
                                long=long+(20*leave.space);
                                ny=leave.y-Math.sin(leave.rad)*long;

                        }
                        if(leave.space==0) long=long+1;
                        renderer.drawSquare(nx,ny,alfaAnnot.color[0].color);

                        data.point=1;
                        var aux=nx*renderer.scale;
                        data.x=Math.round(aux);
                        aux=ny*renderer.scale;
                        data.y=Math.round(aux);
                        aux=20*renderer.scale;
                        data.width=Math.round(aux);
                        aux=20*renderer.scale;
                        data.height=Math.round(aux);
                        res=true;
                    }
                    else return false;
                }
            case "text":
                if(leave.activeAnnotation[annotation]==true){
                    if(alfaAnnot.hasAnnot==true){
                        if(alfaAnnot.text=='H4K5/12'){
                            var i=0;
                            var u=0;
                            var ii=0;
                        }
                        switch(leave.quad){
                            case 1: long=long+(20*leave.space);
                                nx=leave.x+Math.cos(leave.rad)*(long+10);
                                ny=leave.y+Math.sin(leave.rad)*(long+10);
                            case 2: long=long+(20*leave.space);
                                nx=leave.x+Math.cos(leave.rad)*(long+10);
                                ny=leave.y+Math.sin(leave.rad)*(long+10);
                            case 3: long=long+(23*leave.space);
                                ny=leave.y-Math.sin(leave.rad)*(long+10);
                                nx=leave.x-Math.cos(leave.rad)*(long+10);
                            case 4: long=long+(23*leave.space);
                                ny=leave.y-Math.sin(leave.rad)*(long+10);
                                nx=leave.x-Math.cos(leave.rad)*(long+10);
                            case 5: long=long+(20*leave.space);
                                ny=leave.y;
                                nx=leave.x+Math.cos(leave.rad)*(long+10);
                            case 6: long=long+(20*leave.space);
                                ny=leave.y;
                                nx=leave.x-Math.cos(leave.rad)*(long+10);
                            case 7: long=long+(20*leave.space);
                                nx=leave.x;
                                ny=leave.y+Math.sin(leave.rad)*(long+10);
                            case 8: long=long+(20*leave.space);
                                nx=leave.x;
                                ny=leave.y-Math.sin(leave.rad)*(long+5);

                        }
                        renderer.drawText(alfaAnnot.text,nx,ny, -2, 3,0,"start",alfaAnnot.color[0].color);

                        var aux=nx*renderer.scale;

                        data.x=Math.round(nx);
                        data.y=Math.round(ny);
                        data.width=7*alfaAnnot.text.length;
                        data.y=Math.round(ny);
                        data.height=7;
                        data.point=2;
                        res=true;
                    }
                    else return false;
                }

        }

        leave.root.screen[leave.root.screen.length]=data;
        return res;
    }

    public function  updateTreeRectangle(x:Int,y:Int, treeNode: PhyloTreeNode){
        var top:Int;
        top=Std.int(treeNode.rectangleTop);
        var right:Int;
        right=Std.int(treeNode.rectangleRight);
        var bottom:Int;
        bottom=Std.int(treeNode.rectangleBottom);
        var left:Int;
        left=Std.int(treeNode.rectangleLeft);
        x=Std.int(x);
        y=Std.int(y);

        if(x<left){
            treeNode.rectangleLeft=x;
        }
        if(x>right) {
            treeNode.rectangleRight=x;
        }
        if(y<bottom){
            treeNode.rectangleBottom=y;
        }
        if(y>top) {
            treeNode.rectangleTop=y;
        }


    }
}