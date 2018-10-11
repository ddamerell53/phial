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

import saturn.core.Util;


typedef HasAnnotationType = {
    var hasAnnot: Bool;
    var text: String;
    var color: {color:String,used:Bool};
    var defImage: Int;
}

class PhyloAnnotation {
    public var type: Int;
    public var summary: String;
    public var summary_img: Dynamic;
    public var imgtest: String;
    public var annotImg:Array<Dynamic>;
    public var defaultImg:Int;
    public var shape:String;
    public var color:Dynamic;
    public var hookName:String;
    public var text:String;
    public var options:Array<Dynamic>;
    public var optionSelected:Array<Int>;
    public var dbData:Dynamic;
    public var legend:String;
    public var legendClazz:String;
    public var legendMethod:String;
    public var hidden:String;
    public var hasClass:String;
    public var hasMethod: String;
    public var divMethod: String;
    public var familyMethod: String;
    public var hasAnnot: Bool=false;
    public var alfaAnnot: Array<PhyloAnnotation>;
    public var splitresults:Bool;
    public var popup : Bool;
    public var popMethod: String;
    public var multiChoice:Bool;
    public var option:Int;
    public var fromresults:Array<Dynamic>; // used to pass db results
    public var label:String;

    public var myleaf: PhyloTreeNode;
    public var auxMap: Map<String, Dynamic>;


    public function new(){
    //    this.list=PhyloScreenData Array();
        this.color=new Array();
        this.text="";
        this.splitresults=false;
        this.optionSelected=new Array();
        this.alfaAnnot= new Array();
        this.hasAnnot=false;
        this.fromresults= new Array();
        auxMap = new Map<String, Dynamic>();

    }

    public function uploadImg(imgList:Array<Dynamic>){
        var i:Int;
        this.annotImg=new Array();
        for (i in 0 ... imgList.length){
            this.annotImg[i] = js.Browser.document.createElement("img"); // js.Browser.document.createElement("img");
            this.annotImg[i].src = imgList[i];
            this.annotImg[i].onload = function () {
                            //this.ctx.drawImage(this.summary_img, tx, ty);
            }
        }
    }

    public function uploadSpecificImg(imgList:String, pos:Int){
        if (this.annotImg==null) this.annotImg=new Array();
        this.annotImg[pos] = js.Browser.document.createElement("img"); // js.Browser.document.createElement("img");
        this.annotImg[pos].width = 15;
        this.annotImg[pos].src = imgList;
        this.annotImg[pos].onload = function () {
                //this.ctx.drawImage(this.summary_img, tx, ty);
        }
    }

    public function  saveAnnotationData(annotation:Int, data: Dynamic, option:Int, r:Dynamic){ //depending on the annotation, DATA will be different

        this.type=annotation;
        this.dbData=new Array();
        this.dbData=data;
        this.option=option;
        if(r[annotation]!=null){
            //this.defaultImg=r[annotation].defImage;
            if (this.color!=null) this.color=r[annotation].color;
            else{
                this.color=new Array();
                this.color=r[annotation].color;
            }
            this.text=r[annotation].text;
        }
        else {
            this.defaultImg=r.defImage;
            if (this.color!=null) this.color[0]=Util.clone(r.color);
            else{
                this.color=new Array();
                this.color[0]=Util.clone(r.color);
            }
            this.text=''+r.text+'';
        }



        this.hasAnnot=true;
    }

    public function delAnnotation(annotation:Int){

    }


}

