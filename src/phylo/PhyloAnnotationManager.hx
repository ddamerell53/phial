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


import phylo.PhyloAnnotation.HasAnnotationType;

import saturn.db.Provider;
import saturn.client.core.CommonCore;

class PhyloAnnotationManager {
    public var annotations: Array<PhyloAnnotation>;
    public var rootNode : PhyloTreeNode;
    public var canvas : PhyloCanvasRenderer;

    public var treeType : String;
    public var numTotalAnnot: Int;
    public var searchedGenes :Array<String>;
    public var annotationListeners : Array<Void->Void>;

    public var annotationData : Array<Dynamic>;
    public var annotationString : String;
    public var annotationConfigs : Array<PhyloAnnotationConfiguration>;

    public var nameAnnot: Array<String>;
    public var jsonFile : Dynamic;
    public var viewOptions : Array <Dynamic>;
    public var activeAnnotation:Array<Bool>;
    public var alreadyGotAnnotation:Map<String,Bool>;
    public var selectedAnnotationOptions = [];
    public var onSubmenu:Bool=false;
    public var menuScroll=0;

    public var annotationNameToConfig : Map<String, PhyloAnnotationConfiguration>;

    public function new() {
        annotations = new Array<PhyloAnnotation>();
        activeAnnotation=new Array();
        alreadyGotAnnotation=new Map<String, Bool>();
        selectedAnnotationOptions = new Array();
        searchedGenes=new Array();
        annotationListeners = new Array<Void->Void>();
    }

    public function showAssociatedData(active : Bool,  data: PhyloScreenData, mx: Int, my:Int){
        var annotation :Dynamic = annotations[data.annotation.type];

        if(!active && annotation.divMethod != null){
            annotation.divMethod(data, mx, my);
        }
    }

    public function showScreenData(active:Bool, data: PhyloScreenData, mx: Int, my:Int){
        if(this.canvas == null){
            return;
        }

        showAssociatedData(active, data, mx, my);
    }

    public function fillAnnotationwithJSonData(){
        var i=0; var j=0; var z=0;
        nameAnnot=new Array();

        var b=0;
        while(i< jsonFile.btnGroup.length){
            j=0;
            while(j<jsonFile.btnGroup[i].buttons.length){

                //check if it's a subtitle
                if(jsonFile.btnGroup[i].buttons[j].isTitle==false){
                    var a:Int;
                    a=jsonFile.btnGroup[i].buttons[j].annotCode;
                    annotations[a]= new PhyloAnnotation();

                    selectedAnnotationOptions[a] = null;

                    if (jsonFile.btnGroup[i].buttons[j].shape == "image") {
                        annotations[a].uploadImg(jsonFile.btnGroup[i].buttons[j].annotImg); //summary
                    }
//this.activeAnnotation.set(jsonFile.btnGroup[i].buttons[j].annotCode]=false;
                    this.alreadyGotAnnotation[jsonFile.btnGroup[i].buttons[j].annotCode]=false;
                    annotations[a].shape=jsonFile.btnGroup[i].buttons[j].shape;
                    annotations[a].label=jsonFile.btnGroup[i].buttons[j].label;
                    annotations[a].color=jsonFile.btnGroup[i].buttons[j].color;
// annotations[a].type=jsonFile.btnGroup[i].buttons[j].annotCode;
                    annotations[a].hookName=jsonFile.btnGroup[i].buttons[j].hookName;
                    annotations[a].splitresults=jsonFile.btnGroup[i].buttons[j].splitresults;
                    annotations[a].popup=jsonFile.btnGroup[i].buttons[j].popUpWindows;

                    if(jsonFile.btnGroup[i].buttons[j].hasClass!=null) annotations[a].hasClass=jsonFile.btnGroup[i].buttons[j].hasClass;

                    if(jsonFile.btnGroup[i].buttons[j].hasMethod!=null) annotations[a].hasMethod=jsonFile.btnGroup[i].buttons[j].hasMethod;
                    if(jsonFile.btnGroup[i].buttons[j].divMethod!=null) annotations[a].divMethod=jsonFile.btnGroup[i].buttons[j].divMethod;
                    if(jsonFile.btnGroup[i].buttons[j].familyMethod!=null) annotations[a].familyMethod=jsonFile.btnGroup[i].buttons[j].familyMethod;
                    if(jsonFile.btnGroup[i].buttons[j].popUpWindows!=null && jsonFile.btnGroup[i].buttons[j].popUpWindows==true){
                        annotations[a].popMethod=jsonFile.btnGroup[i].buttons[j].windowsData[0].popMethod;
                    }

                    annotations[a].options=new Array();
                    if(jsonFile.btnGroup[i].buttons[j].legend!=null){
                        annotations[a].legend=jsonFile.btnGroup[i].buttons[j].legend.image;

                        if(jsonFile.btnGroup[i].buttons[j].legend.clazz != null) {
                            annotations[a].legendClazz = jsonFile.btnGroup[i].buttons[j].legend.clazz;
                            annotations[a].legendMethod = jsonFile.btnGroup[i].buttons[j].legend.method;
                        }else if(jsonFile.btnGroup[i].buttons[j].legend.method != null) {
                            annotations[a].legendMethod = jsonFile.btnGroup[i].buttons[j].legend.method;
                        }
                    }

                    if(jsonFile.btnGroup[i].buttons[j].hidden != null){
                        annotations[a].hidden = jsonFile.btnGroup[i].buttons[j].hidden;
                    }

                    if(jsonFile.btnGroup[i].buttons[j].submenu==true){
                        var zz:Int;
                        for (zz in 0 ...jsonFile.btnGroup[i].buttons[j].options.length){
                            annotations[a].options[zz]=jsonFile.btnGroup[i].buttons[j].options[zz].hookName;
                            if(jsonFile.btnGroup[i].buttons[j].options[zz].defaultImg!=null)
                                annotations[a].defaultImg=jsonFile.btnGroup[i].buttons[j].options[zz].defaultImg;
                        }
                        annotations[a].optionSelected[0] = jsonFile.btnGroup[i].buttons[j].optionSelected[0];
                    }
                    nameAnnot[b]=jsonFile.btnGroup[i].buttons[j].label;
                    b++;
                }
                j++;
            }
            numTotalAnnot=numTotalAnnot+j;
            i++;
        }
    }


    public function setSelectedAnnotationOptions(annotation : Int, selectedOptions : Dynamic){
        selectedAnnotationOptions[annotation] = selectedOptions;
    }

    public function getSelectedAnnotationOptions(annotation : Int) : Dynamic{
        return selectedAnnotationOptions[annotation];
    }


    public function closeAnnotWindows(){

    }


    function generateIcon(j:Int, tarname:String,results:Array<Int>):String{
        var name=tarname;
        if(name.indexOf('(')!=-1 || name.indexOf('/')!=-1){
            var auxArray=name.split('');
            var j:Int;
            var nn='';
            for(j in 0...auxArray.length){
                if (auxArray[j]!='(' && auxArray[j]!=')' && auxArray[j]!='/') {
                    nn=nn+auxArray[j];
                }
            }
            name=nn;
        }
        var r1=23-results[1];
        var r2=23-results[2];
        var r3=23-results[3];
        var r4=23-results[4];
        var r5=23-results[5];
        var r6=23-results[6];
        var r7=23-results[7];
        return "<script type=\"text/javascript\">
        $('.horizontal .progress-fill span').each(function(){
  var percent = $(this).html();
  $(this).parent().css('width', percent);
});


$('.vertical .progress-fill span').each(function(){
  var percent = $(this).html();
  var pTop = 100 - ( percent.slice(0, percent.length - 1) ) + \"%\";
  $(this).parent().css({
    'height' : percent,
    'top' : pTop
  });
});
                </script>"+'
                <style type="text/css" media="all">
                *, *:before, *:after {
  -moz-box-sizing: border-box; -webkit-box-sizing: border-box; box-sizing: border-box;
 }
.container {
  width: 23px;
  height: 23px;
  background: #fff;
  overflow: hidden;
  border-bottom:1px solid #000;
}

.vertical .progress-bar {
  float: left;
  height: 100%;
  width: 3px;
}

.vertical .progress-track {
  position: relative;
  width: 3px;
  height: 100%;
  background: #ffffff;
}

.vertical .progress-track-1 {
   position: relative;
   width: 3px;
   height: 100%;
   background: #2980d6;
}
.vertical .progress-fill-1'+name+' {
  position: relative;
  height: '+r1+'px;
  width: 3px;
  background-color:#ffffff;
}

.vertical .progress-track-2 {
   position: relative;
   width: 3px;
   height: 100%;
   background: #bf0000;
}
.vertical .progress-fill-2'+name+' {
  position: relative;
  height: '+r2+'px;
  width: 3px;
  background-color:#ffffff;
}
.vertical .progress-track-3 {
  position: relative;
   width: 3px;
   height: 100%;
   background: #63cf1b;
}
.vertical .progress-fill-3'+name+' {
  position: relative;
  height: '+r3+'px;
  width: 3px;
  background-color:#ffffff;
}
.vertical .progress-track-4 {
  position: relative;
   width: 3px;
   height: 100%;
   background: #ff8000;
}
.vertical .progress-fill-4'+name+' {
  position: relative;
  height: '+r4+'px;
  width: 3px;
  background-color:#ffffff;
}
.vertical .progress-track-5 {
  position: relative;
   width: 3px;
   height: 100%;
   background: #c05691;
}
.vertical .progress-fill-5'+name+' {
  position: relative;
  height: '+r5+'px;
  width: 3px;
  background-color:#ffffff;
}
.vertical .progress-fill-6'+name+' {
  position: relative;
  height: '+r6+'px;
  width: 3px;
  background-color:#ffffff;
}
.vertical .progress-track-6 {
  position: relative;
   width: 3px;
   height: 100%;
   background: #ffcc00;
}
.vertical .progress-track-7 {
  position: relative;
   width: 3px;
   height: 100%;
   background: #793ff3;
}
.vertical .progress-fill-7'+name+' {
  position: relative;
  height: '+r7+';
  width: 3px;
  background-color:#ffffff;
}
                </style>
                '+'<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().annotationManager.showDivInTable('+j+',\''+tarname+'\')";return false;">
                <div class="container vertical flat">
                          <div class="progress-bar">
                            <div class="progress-track-1">
                              <div class="progress-fill-1'+name+'">
                                <span> </span>
                              </div>
                            </div>
                          </div>

                          <div class="progress-bar">
                            <div class="progress-track-2">
                              <div class="progress-fill-2'+name+'">
                                <span> </span>
                              </div>
                            </div>
                          </div>

                          <div class="progress-bar">
                            <div class="progress-track-3">
                              <div class="progress-fill-3'+name+'">
                                <span> </span>
                              </div>
                            </div>
                          </div>

                          <div class="progress-bar">
                            <div class="progress-track-4">
                              <div class="progress-fill-4'+name+'">
                                <span> </span>
                              </div>
                            </div>
                          </div>

                          <div class="progress-bar">
                            <div class="progress-track-5">
                              <div class="progress-fill-5'+name+'">
                                <span> </span>
                              </div>
                            </div>
                          </div>

                          <div class="progress-bar">
                            <div class="progress-track-6">
                              <div class="progress-fill-6'+name+'">
                                <span> </span>
                              </div>
                            </div>
                          </div>

                          <div class="progress-bar">
                            <div class="progress-track-7">
                              <div class="progress-fill-7'+name+'">
                                <span> </span>
                              </div>
                            </div>
                          </div>
                        </div></a>';
    }



    public function addAnnotData(annotData  : Array<Dynamic>, annotation: Int, option:Int, callback:Void->Void ){
        var i:Int;
        var mapResults: Map<String, Dynamic>;
        mapResults=new Map();
        var j=0;
        var target:String;
        for(i in 0 ... annotData.length){

            target=annotData[i].target_id+'_'+j;
            while (mapResults.exists(target)){
                j++;
                target=annotData[i].target_id+'_'+j;
            }
            j=0;
            mapResults.set(target, annotData[i]);
        }

        //creating target list to be processed
        var items=new Array();
        for(i in 0 ... this.rootNode.targets.length){
            items[i]=this.rootNode.targets[i];
        }

        processAnnotationsSimple(items,mapResults,annotation, option, callback);
    }

    public function processAnnotationsSimple(items:Array<String>,mapResults: Map<String, Dynamic>,annotation: Int, option:Int, cb:Void->Void){
        var toComplete = items.length;
        var onDone = function(){
            if(toComplete  == 0){
                cb();
            }
        };

        if(toComplete == 0){
            cb();return;
        }

        for(item in items){
            var name = item + '_0';
            var res = mapResults.get(name);
            if((annotations[annotation].hasClass != null)&&(annotations[annotation].hasMethod != null)){
                var clazz = annotations[annotation].hasClass;
                var method :Dynamic = annotations[annotation].hasMethod;

                var _processAnnotation = function(r:HasAnnotationType){
                    if(r.hasAnnot){
                        var leafaux: PhyloTreeNode;
                        leafaux = this.rootNode.leafNameToNode.get(item);

                        leafaux.activeAnnotation[annotation] = true;
                        if(leafaux.annotations[annotation] == null){
                            leafaux.annotations[annotation] = new PhyloAnnotation();
                            leafaux.annotations[annotation].myleaf = leafaux;
                            leafaux.annotations[annotation].text = r.text;
                            leafaux.annotations[annotation].defaultImg = annotations[annotation].defaultImg;
                            leafaux.annotations[annotation].saveAnnotationData(annotation,res,option,r);
                        }else{
                            if(annotations[annotation].splitresults == true){
                                leafaux.annotations[annotation].splitresults = true;

                                var z=0;

                                while(leafaux.annotations[annotation].alfaAnnot[z] != null){
                                    z++;
                                }

                                leafaux.annotations[annotation].alfaAnnot[z] = new PhyloAnnotation();
                                leafaux.annotations[annotation].alfaAnnot[z].myleaf = leafaux;
                                leafaux.annotations[annotation].alfaAnnot[z].text = '';
                                leafaux.annotations[annotation].alfaAnnot[z].defaultImg = annotations[annotation].defaultImg;
                                leafaux.annotations[annotation].alfaAnnot[z].saveAnnotationData(annotation,res,option,r);
                                if(leafaux.annotations[annotation].alfaAnnot[z].text == leafaux.annotations[annotation].text){
                                    leafaux.annotations[annotation].alfaAnnot[z] = null;
                                }
                            }else{
                                if(leafaux.annotations[annotation].option != annotations[annotation].optionSelected[0]){
                                    leafaux.annotations[annotation] = new PhyloAnnotation();
                                    leafaux.annotations[annotation].myleaf = leafaux;
                                    leafaux.annotations[annotation].text = '';
                                    leafaux.annotations[annotation].defaultImg = annotations[annotation].defaultImg;
                                    leafaux.annotations[annotation].saveAnnotationData(annotation,res,option,r);
                                }
                            }
                        }
                    }

                    toComplete--;
                    onDone();
                };

                if(Reflect.isFunction(method)){
                    method(name,res,option, annotations, item, _processAnnotation);
                }else{
                    var hook : Dynamic = Reflect.field(Type.resolveClass(clazz), method);

                    hook(name,res,option, annotations, item, _processAnnotation);
                }
            }else {
                var col = '';
                if(annotations[annotation].color[0] != null){
                    col=annotations[annotation].color[0].color;
                }

                var r : HasAnnotationType = {hasAnnot : true, text : '',color : {color : col, used : true},defImage : annotations[annotation].defaultImg};

                var leafaux: PhyloTreeNode = this.rootNode.leafNameToNode.get(item);
                leafaux.activeAnnotation[annotation]=true;

                if(leafaux.annotations[annotation] == null){
                    leafaux.annotations[annotation] = new PhyloAnnotation();
                    leafaux.annotations[annotation].myleaf = leafaux;
                    leafaux.annotations[annotation].text = '';
                    leafaux.annotations[annotation].defaultImg = annotations[annotation].defaultImg;
                    leafaux.annotations[annotation].saveAnnotationData(annotation,res,option,r);
                }else{
                    if(leafaux.annotations[annotation].splitresults == true){
                        var z=0;

                        while(leafaux.annotations[annotation].alfaAnnot[z]!=null){
                            z++;
                        }

                        leafaux.annotations[annotation].alfaAnnot[z] = new PhyloAnnotation();
                        leafaux.annotations[annotation].alfaAnnot[z].myleaf = leafaux;
                        leafaux.annotations[annotation].alfaAnnot[z].text = '';
                        leafaux.annotations[annotation].alfaAnnot[z].defaultImg = annotations[annotation].defaultImg;
                        leafaux.annotations[annotation].alfaAnnot[z].saveAnnotationData(annotation,res,option,r);

                    }else{
                        if(leafaux.annotations[annotation].option != annotations[annotation].optionSelected[0]){
                            leafaux.annotations[annotation] = new PhyloAnnotation();
                            leafaux.annotations[annotation].myleaf = leafaux;
                            leafaux.annotations[annotation].text = '';
                            leafaux.annotations[annotation].defaultImg = annotations[annotation].defaultImg;
                            leafaux.annotations[annotation].saveAnnotationData(annotation,res,option,r);
                        }
                    }
                }

                toComplete--;
                onDone();
            }
        }
    }


    /**
    * processFamilyAnnotations
    *
    * TODO: Fully document this function especially around Sefa's code to handle variants and indexes as I don't understand this
    **/
    public function processFamilyAnnotations(items:Array<String>,mapResults: Map<String, Dynamic>,annotation: Int, option:Int, cb:Void->Void){
        var toComplete = 0;

        // First we work out how many annotations we need to process
        // We do this so that it's easy for our onDone function to work out when all async callbacks have finished
        // We used to use a timer to wait for all the callbacks to finish but that's not necessary
        for(item in items){
            var name  = '';
            var hookCount = 0;

            var index = null;
            var variant = '1';
            var hasName = false;

            if(item.indexOf('(') != -1 || item.indexOf('-') != -1){
                hasName = true;

                var auxArray = item.split('');

                for(j in 0...auxArray.length){
                    if(auxArray[j] == '(' || auxArray[j] == '-'){
                        if(auxArray[j] == '(') {
                            index  = auxArray[j+1];
                            variant = '1';
                        }else if(auxArray[j] == '-') {
                            index = null;
                            variant = auxArray[j+1];
                        }

                        break;
                    }

                    name += auxArray[j];
                }
            }else{
                name = item;
            }

            var j = 0;
            var finished = false;
            var showAsSgc = false;

            while((mapResults.exists(name+'_'+j)==true)&&(finished==false)){
                var keepgoing=true;
                var res=mapResults.get(name+'_'+j);

                if (mapResults.get(name+'_'+ j).sgc == 1 || showAsSgc == true) {
                    res.sgc = 1;
                    showAsSgc = true;
                }

                if(hasName==true){
                    if(res.target_name_index!=index || res.variant_index!=variant){
                        keepgoing=false;
                    }
                }
                if(keepgoing==false){
                    j++;
                }else{
                    toComplete += 1;
                    if((annotations[annotation].hasClass!=null)&&(annotations[annotation].hasMethod!=null)){
                        j++;
                    }else{
                        finished=true;
                    }
                }
            }
        }


        var onDone = function(){
            if(toComplete  == 0){
                cb();
            }
        };

        if(toComplete == 0){
            cb();return;
        }

        for(item in items){
            var hookCount = 0;

            var index = null;
            var variant = '1';
            var hasName = false;
            var name = '';

            if(item.indexOf('(') != -1 || item.indexOf('-') != -1){
                hasName = true;

                var auxArray = item.split('');

                for(j in 0...auxArray.length){
                    if(auxArray[j] == '(' || auxArray[j] == '-'){
                        if(auxArray[j] == '(') {
                            index  = auxArray[j+1];
                            variant = '1';
                        }else if(auxArray[j] == '-') {
                            index = null;
                            variant = auxArray[j+1];
                        }

                        break;
                    }

                    name += auxArray[j];
                }
            }else{
                name = item;
            }

            var j = 0;
            var finished = false;
            var showAsSgc = false;

            while((mapResults.exists(name+'_'+j) == true) && (finished == false)){
                var keepGoing = true;
                var res = mapResults.get(name+'_'+j);

                if(mapResults.get(name+'_'+ j).sgc == 1 || showAsSgc == true) {
                    res.sgc = 1;
                    showAsSgc = true;
                }

                if(hasName==true){
                    if(res.target_name_index != index || res.variant_index != variant){
                        keepGoing=false;
                    }
                }

                if(keepGoing==false){
                    j++;
                }else{
                    if((annotations[annotation].hasClass != null)&&(annotations[annotation].hasMethod != null)){
                        var clazz = annotations[annotation].hasClass;
                        var method :Dynamic = annotations[annotation].hasMethod;

                        var _processAnnotation = function(r:HasAnnotationType){
                            if(r.hasAnnot){
                                var leafaux: PhyloTreeNode;
                                leafaux = this.rootNode.leafNameToNode.get(item);

                                leafaux.activeAnnotation[annotation] = true;
                                if(leafaux.annotations[annotation] == null){
                                    leafaux.annotations[annotation] = new PhyloAnnotation();
                                    leafaux.annotations[annotation].myleaf = leafaux;
                                    leafaux.annotations[annotation].text = r.text;
                                    leafaux.annotations[annotation].defaultImg = annotations[annotation].defaultImg;
                                    leafaux.annotations[annotation].saveAnnotationData(annotation,res,option,r);
                                }else{
                                    if(annotations[annotation].splitresults == true){
                                        leafaux.annotations[annotation].splitresults = true;

                                        var z=0;

                                        while(leafaux.annotations[annotation].alfaAnnot[z] != null){
                                            z++;
                                        }

                                        leafaux.annotations[annotation].alfaAnnot[z] = new PhyloAnnotation();
                                        leafaux.annotations[annotation].alfaAnnot[z].myleaf = leafaux;
                                        leafaux.annotations[annotation].alfaAnnot[z].text = '';
                                        leafaux.annotations[annotation].alfaAnnot[z].defaultImg = annotations[annotation].defaultImg;
                                        leafaux.annotations[annotation].alfaAnnot[z].saveAnnotationData(annotation,res,option,r);
                                        if(leafaux.annotations[annotation].alfaAnnot[z].text == leafaux.annotations[annotation].text){
                                            leafaux.annotations[annotation].alfaAnnot[z] = null;
                                        }
                                    }else{
                                        if(leafaux.annotations[annotation].option != annotations[annotation].optionSelected[0]){
                                            leafaux.annotations[annotation] = new PhyloAnnotation();
                                            leafaux.annotations[annotation].myleaf = leafaux;
                                            leafaux.annotations[annotation].text = '';
                                            leafaux.annotations[annotation].defaultImg = annotations[annotation].defaultImg;
                                            leafaux.annotations[annotation].saveAnnotationData(annotation,res,option,r);
                                        }
                                    }
                                }
                            }

                            toComplete--;
                            onDone();
                        };

                        if(Reflect.isFunction(method)){
                            method(name,res,option, annotations, item, _processAnnotation);
                        }else{
                            var hook : Dynamic = Reflect.field(Type.resolveClass(clazz), method);

                            hook(name,res,option, annotations, item, _processAnnotation);
                        }

                        j++;
                    }else {
                        finished=true;

                        var col = '';
                        if(annotations[annotation].color[0] != null){
                            col=annotations[annotation].color[0].color;
                        }

                        var r : HasAnnotationType = {hasAnnot : true, text : '',color : {color : col, used : true},defImage : annotations[annotation].defaultImg};

                        var leafaux: PhyloTreeNode = this.rootNode.leafNameToNode.get(item);
                        leafaux.activeAnnotation[annotation]=true;

                        if(leafaux.annotations[annotation] == null){
                            leafaux.annotations[annotation] = new PhyloAnnotation();
                            leafaux.annotations[annotation].myleaf = leafaux;
                            leafaux.annotations[annotation].text = '';
                            leafaux.annotations[annotation].defaultImg = annotations[annotation].defaultImg;
                            leafaux.annotations[annotation].saveAnnotationData(annotation,res,option,r);
                        }else{
                            if(leafaux.annotations[annotation].splitresults == true){
                                var z=0;

                                while(leafaux.annotations[annotation].alfaAnnot[z]!=null){
                                    z++;
                                }

                                leafaux.annotations[annotation].alfaAnnot[z] = new PhyloAnnotation();
                                leafaux.annotations[annotation].alfaAnnot[z].myleaf = leafaux;
                                leafaux.annotations[annotation].alfaAnnot[z].text = '';
                                leafaux.annotations[annotation].alfaAnnot[z].defaultImg = annotations[annotation].defaultImg;
                                leafaux.annotations[annotation].alfaAnnot[z].saveAnnotationData(annotation,res,option,r);

                            }else{
                                if(leafaux.annotations[annotation].option != annotations[annotation].optionSelected[0]){
                                    leafaux.annotations[annotation] = new PhyloAnnotation();
                                    leafaux.annotations[annotation].myleaf = leafaux;
                                    leafaux.annotations[annotation].text = '';
                                    leafaux.annotations[annotation].defaultImg = annotations[annotation].defaultImg;
                                    leafaux.annotations[annotation].saveAnnotationData(annotation,res,option,r);
                                }
                            }
                        }

                        toComplete--;
                        onDone();
                    }
                }
            }
        }
    }

    /**Function used to remove the previous results of a PopUp Window Annotations. **/
    public function cleanAnnotResults(annot:Int){

        var items=new Array();
        for(i in 0 ... this.rootNode.targets.length){
            var item=this.rootNode.targets[i];

            var leafaux=this.rootNode.leafNameToNode.get(item);
            if(leafaux.annotations[annot]!=null) leafaux.annotations[annot].hasAnnot=false;
        }
    }



    // Code below is all new and not used by UbiHub or ChromoHub but attempts to remain compatible with their API

    public function reloadAnnotationConfigurations(){
        setAnnotationConfigs(getAnnotationConfigs(), true, function(){

        });
    }

    public function setAnnotationConfigs(configs : Array<PhyloAnnotationConfiguration>, restoreData : Bool, cb : Void->Void){
        this.annotationConfigs = configs;

        annotationNameToConfig = new Map<String, PhyloAnnotationConfiguration>();

        for(config in annotationConfigs){
            annotationNameToConfig.set(config.name, config);
        }

        var oldData = annotationData;

        annotationData = new Array<Dynamic>();

        var activeAnnotationNames = new Map<String, String>();

        CommonCore.getDefaultProvider(function(err :String, provider : Provider){
            if(err == null && provider != null){
                provider.resetCache();

                for(i in 0...activeAnnotation.length){
                    if(activeAnnotation[i]){
                        activeAnnotationNames.set(annotations[i].label, '');

                        activeAnnotation[i] = false;
                    }
                }

                if(rootNode != null){
                    rootNode.clearAnnotations();
                }

                annotations = [];

                jsonFile = {btnGroup:[{title:'Annotations', buttons:[]}]};

                for(i in 0...configs.length){
                    var config = configs[i];

                    annotationData[i] = [];

                    // For now we have to mirror the complicated configured the ChromoHub / UbiHub interface expects

                    var hookName = 'STANDALONE_ANNOTATION_' + (i);

                    var def = {
                        label: config.name,
                        hookName: hookName,
                        annotCode: i+1,
                        isTitle: false,
                        enabled:true,
                        familyMethod: '',
                        hasMethod: config.styleFunction,
                        hasClass: '',
                        legend: {method:config.legendFunction},
                        divMethod : config.infoFunction,
                        color: [
                            {color:config.colour, used:"false"}
                        ],
                        shape:config.shape,
                    };

                    jsonFile.btnGroup[0].buttons.push(def);

                    CommonCore.getDefaultProvider(function(error, provider : Provider){
                        //TODO: Important!!!
                        provider.resetCache();

                        provider.addHook(config.annotationFunction, hookName);
                    });
                }

                fillAnnotationwithJSonData();

                if(restoreData){
                    annotationData = oldData;
                }

                annotationsChanged(activeAnnotationNames);

                cb();
            };
        });
    }

    public function getAnnotationConfigs(): Array<PhyloAnnotationConfiguration> {
        return this.annotationConfigs;
    }

    public function getAnnotationConfigByName(name : String) : PhyloAnnotationConfiguration{
        return annotationNameToConfig.get(name);
    }

    public function getAnnotationConfigById(id : Int) : PhyloAnnotationConfiguration{
        return getAnnotationConfigByName(annotations[id].label);
    }

    public function loadAnnotationsFromString(annotationString : String, configs : Array<PhyloAnnotationConfiguration> = null){
        this.annotationString = annotationString;

        var lines = annotationString.split('\n');
        var header = lines[0];
        var cols = header.split(',');

        var configMap = new Map<String, PhyloAnnotationConfiguration>();

        if(configs != null){
            for(config in configs){
                configMap.set(config.name, config);
            }
        }

        var finalConfigs = new Array<PhyloAnnotationConfiguration>();

        for(i in 1...cols.length){
            var styleAnnotation = function (target: String, data: Dynamic, selected:Int, annotList:Array<PhyloAnnotation>, item:String, callBack : HasAnnotationType->Void){
                var config = getAnnotationConfigById(selected);

                var r : HasAnnotationType = {hasAnnot: true, text:'',color:config.getColourOldFormat(),defImage:100};

                if(data == null || data.annotation == 'No'){
                    r.hasAnnot = false;
                }

                callBack(r);
            };

            var legendMethod = function(legendWidget : PhyloLegendWidget, config : PhyloAnnotationConfiguration){
                var row = new PhyloLegendRowWidget(legendWidget, config);
            }

            var divMethod = function(data: PhyloScreenData, mx: Int, my:Int){
                var window = new PhyloWindowWidget(js.Browser.document.body,data.target, false);
                var container = window.getContainer();

                container.style.left = mx;
                container.style.top = my;

                container.style.width = '400px';
                container.style.height = '200px';
            }

            var name = cols[i];

            var hookFunction = handleAnnotation;

            var config :PhyloAnnotationConfiguration = new PhyloAnnotationConfiguration();

            config.shape = 'cercle';
            config.colour = 'green';
            config.name = name;
            config.styleFunction= styleAnnotation;
            config.annotationFunction = hookFunction;
            config.infoFunction = divMethod;
            config.legendFunction = legendMethod;

            if(configMap.exists(name)){
                var configUser :PhyloAnnotationConfiguration = configMap.get(name);

                if(configUser.colour != null){
                    config.colour = configUser.colour;
                }

                if(configUser.annotationFunction != null){
                    config.annotationFunction = configUser.annotationFunction;
                }

                if(configUser.styleFunction != null){
                    config.styleFunction = configUser.styleFunction;
                }

                if(configUser.legendFunction != null){
                    config.legendFunction = configUser.legendFunction;
                }

                if(configUser.shape != null){
                    config.shape = configUser.shape;
                }
            }

            finalConfigs.push(config);
        }

        annotationData = [];

        var headerCols = header.split(',');

        for(j in 1...headerCols.length){
            annotationData[j-1] = [];
        }

        for(i in 1...lines.length){
            var cols = lines[i].split(',');

            for(j in 1...cols.length){
                annotationData[j-1].push({'target_id': cols[0], 'annotation': cols[j]});
            }
        }

        setAnnotationConfigs(finalConfigs, true, function(){
            //
        });
    }

    // Below has been added after the creation of ChromoHub and UbiHub and aren't yet used by either

    public function handleAnnotation(alias : String, params, clazz, cb : Dynamic->String->Void){
        var annotationIndex = Std.parseInt(alias.charAt(alias.length-1));

        cb(annotationData[annotationIndex], null);
    }

    public function addAnnotationListener(listener : Void->Void){
        annotationListeners.push(listener);
    }

    public function annotationsChanged(activeAnnotationNames : Map<String, String> = null){
        if(activeAnnotationNames != null){
            if(canvas != null && canvas.getConfig().enableAnnotationMenu){
                canvas.getAnnotationMenu().update(activeAnnotationNames);

                return;
            }
        }

        for(listener in annotationListeners){
            listener();
        }
    }

    public function toggleAnnotation(annotCode : Dynamic){
        if(isAnnotationActive(annotCode)){
            setActiveAnnotation(annotCode, false);
        }else{
            setActiveAnnotation(annotCode, true);
        }
    }

    public function isAnnotationActive(annotCode : Dynamic) : Bool {
        return activeAnnotation[annotCode];
    }

    public function setActiveAnnotation(annotCode : Dynamic, active: Bool){
        activeAnnotation[annotCode]=active;

        if(active){
            var annot=annotations[annotCode];

            CommonCore.getDefaultProvider(function(err : String, provider : Provider){
                var parameters = canvas.getRootNode().targets;

                provider.getByNamedQuery(annot.hookName,{param : parameters}, null, true, function(db_results, error){
                    if(error == null) {
                        canvas.getAnnotationManager().addAnnotData(db_results,annotCode,annotCode, function(){
                            annotationsChanged();
                        });
                    }
                });
            });
        }else{
            annotationsChanged();
        }
    }

    public function getActiveAnnotations() : Array<Dynamic>{
        var annotations = new Array<Dynamic>();

        for(i in 0...activeAnnotation.length){
            if(activeAnnotation[i]){
                annotations.push(this.annotations[i]);
            }
        }

        return annotations;
    }

    public function getAnnotationString(): String{
        return annotationString;
    }

    public function setRootNode(rootNode : PhyloTreeNode){
        this.rootNode = rootNode;
    }

    public function getTreeName() : String{
        return 'tree';
    }

    public function hideAnnotationWindows(){

    }
}

