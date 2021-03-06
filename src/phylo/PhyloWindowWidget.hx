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

class PhyloWindowWidget {
    public var container : Dynamic;
    public var content : Dynamic;
    public var parent : Dynamic;
    public var header : Dynamic;
    public var title : String;
    public var modal : Bool;
    public var onCloseFunc : Dynamic;

    public function new(parent : Dynamic, title : String = null, modal = false) {
        this.parent = parent;
        this.title = title;
        this.modal = modal;

        build();
    }

    public function setOnCloseEvent(func : Dynamic){
        onCloseFunc = func;
    }

    public function build(){
        addContainer();

        addWindowHeader();

        addContent();

        container.appendChild(content);
    }

    public function getContainer() : Dynamic{
        return container;
    }

    public function getContent() : Dynamic {
        return content;
    }

    public function addContainer(){
        container = js.Browser.document.createElement('div');
        container.classList.add('popup-window');
        container.style.position = 'fixed';
        container.style.zIndex = 1;
        container.style.left = 0;
        container.style.top = 0;
        container.style.minWidth = '200px';
        container.style.minHeight = '100px';
        container.style.overflow = 'hidden';
        container.style.border = '1px solid rgb(195, 195, 195)';
        container.style.borderRadius = '6px';

        parent.appendChild(container);
    }

    public function isModal() : Bool{
        return modal;
    }

    public function addWindowHeader(){
        header = js.Browser.document.createElement('div');
        header.classList.add('popup-header');
        header.style.position = 'absolute';
        header.style.top = '0px';
        header.style.backgroundColor = 'rgb(125, 117, 117)';
        header.style.height = '24px';
        header.style.width = '100%';
        header.style.padding = '4px 15px 4px 15px';
        header.style.lineHeight = '16px';
        header.style.boxSizing = "border-box";
        header.style.cursor = 'pointer';

        addTitle();
        addCloseButton();

        if(!isModal()){
            installMoveListeners();
        }

        container.appendChild(header);
    }

    public function addTitle(){
        var titleSpan = js.Browser.document.createElement('span');
        titleSpan.innerText = this.title;

        titleSpan.style.color = 'white';
        titleSpan.style.fontSize = '18px';
        titleSpan.style.fontWeight = 'bold';

        header.appendChild(titleSpan);
    }

    public function addCloseButton(){
        var closeButton = js.Browser.document.createElement('span');
        closeButton.style.color = 'white';
        closeButton.style.float = 'right';
        closeButton.style.fontSize = '24px';
        closeButton.style.fontWeight = 'bold';
        closeButton.innerHTML = '&times;';
        closeButton.style.cursor = 'pointer';

        closeButton.addEventListener('click', function(e){
            close();
        });

        header.appendChild(closeButton);
    }

    public function addContent(){


        content = js.Browser.document.createElement('div');
        content.classList.add('popup-content');
        content.style.backgroundColor = 'rgb(247, 248, 251)';
        content.style.width = '100%';
        content.style.display = 'table';
        content.style.padding = '37px 15px 15px 15px';
        content.style.boxSizing = "border-box";
    }

    public function close(){
        onClose();

        parent.removeChild(container);
    }

    public function onClose(){
        if(onCloseFunc != null){
            onCloseFunc(this);
        }
    }

    public function installMoveListeners(){
        var isDown = false;
        var offsetX = 0.;
        var offsetY = 0.;

        var moveListener = function(event) {
            event.preventDefault();

            if (isDown) {
                container.style.left = (event.clientX + offsetX) + 'px';
                container.style.top  = (event.clientY + offsetY) + 'px';
            }
        };

        header.addEventListener('mousedown', function(e) {
            isDown = true;

            offsetX = container.offsetLeft - e.clientX;
            offsetY = container.offsetTop - e.clientY;

            js.Browser.document.body.addEventListener('mousemove', moveListener);

        });

        header.addEventListener('mouseup', function() {
            isDown = false;
            js.Browser.document.body.removeEventListener('mousemove', moveListener);

        });
    }
}