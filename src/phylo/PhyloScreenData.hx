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

class PhyloScreenData {

    public var point: Int; //it will tell us whether the annotation icon position is based on 1 = middle point, 2 = left top point, 3=...
    public var x: Int; //x and y positions
    public var y: Int;
    public var parentx:Int;
    public var parenty: Int;
    public var width: Int;
    public var height: Int;
    public var annotation: PhyloAnnotation;
    public var created:Bool; //whether the DIV is already created
    public var target:String;
    public var targetClean:String;
    public var annot:Int;
    public var root: PhyloTreeNode;
    public var div:Dynamic;
    public var divAccessed:Bool;
    public var suboption: Int=0;
    public var family:String;
    public var renderer: PhyloCanvasRenderer;
    public var isAnnot:Bool;
    public var nodeId:Int;
    public var title:String; //annotation name



    public function new(){
        this.annotation=new PhyloAnnotation();
        this.created=false;
        this.divAccessed=false;
    }

    @:keep
    public function checkMouse(mx:Int,my:Int){
        var scaleX=x*renderer.scale;
        var scaleY=y*renderer.scale;
        var scaleWidth=(width)*renderer.scale;
        var scaleHeight=(height)*renderer.scale;

        switch(this.point){
            case 1: if((mx>=scaleX)&&(mx<(scaleX+scaleWidth))&&(my<(scaleY+scaleHeight))&&(my>=scaleY)) {
                   /* WorkspaceApplication.getApplication().debug('x is '+x);
                    WorkspaceApplication.getApplication().debug('width is '+width);
                    WorkspaceApplication.getApplication().debug('y is '+y);
                    WorkspaceApplication.getApplication().debug('height is '+height);*/
                    return true;
                }
                    else return false;
            case 2://text
                if((mx>=scaleX)&&(mx<(scaleX+scaleWidth))&&(my>(scaleY-scaleHeight))&&(my<=scaleY)) {
                    /* WorkspaceApplication.getApplication().debug('x is '+x);
                    WorkspaceApplication.getApplication().debug('width is '+width);
                    WorkspaceApplication.getApplication().debug('y is '+y);
                    WorkspaceApplication.getApplication().debug('height is '+height);*/
                    return true;
                }else{
                    return false;
                }
            case 3: // circle
                scaleWidth=(width*renderer.scale)/2;
                scaleHeight=(height*renderer.scale)/2;

                var inXBoundary = ((mx>=scaleX) && (mx<(scaleX+scaleWidth))) || ((mx<=scaleX) && (mx>(scaleX - scaleWidth)));
                var inYBoundary = (((my>(scaleY-scaleHeight))&&(my<=scaleY)))||((my<(scaleY+scaleHeight))&&(my>scaleY));

                if(inXBoundary && inYBoundary){
                    /**
                    WorkspaceApplication.getApplication().debug('mx is '+mx);
                    WorkspaceApplication.getApplication().debug('my is '+my);
                    WorkspaceApplication.getApplication().debug('scaleX is '+scaleX);
                    WorkspaceApplication.getApplication().debug('scaleY is '+scaleY);
                    WorkspaceApplication.getApplication().debug('scaleWidth is '+scaleWidth);
                    WorkspaceApplication.getApplication().debug('scaleHeight is '+scaleHeight); */
                    return true;
                }
                else return false;
            case 4: // square
                if((mx>=scaleX)&&(mx<(scaleX+scaleWidth))&&(my<(scaleY+scaleHeight))&&(my>=scaleY)) {
                  /*  WorkspaceApplication.getApplication().debug('x is '+x);
                    WorkspaceApplication.getApplication().debug('width is '+width);
                    WorkspaceApplication.getApplication().debug('y is '+y);
                    WorkspaceApplication.getApplication().debug('height is '+height);*/
                    return true;
                }
                else return false;
            case 5: // non leave node
                // The +5 and -5 are being used introduce a tolerance in how close users need to click on internal nodes.
                // Note that for the Y axis we are making the hit box taller centered around the internal node.
                // For some reason we have to reduce the hit box width to get the required affect for users.
                // TODO: Investigate Sefa's code to work out why this is happening.
                if((mx+5>=scaleX)&&(mx<(scaleX+scaleWidth-5))&&(my<(scaleY+scaleHeight+5))&&(my>=scaleY-5)){
                    return true;
                }else{
                    return false;
                }
            default:return false;
        }
    }

}

