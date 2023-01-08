module prizm_add_dfask(n, height, rib, r_fask, fn_fask, center = false)
{
  r = rib/sqrt(3);
  minkowski()
  {
    cylinder(height/2, r, r, $fn=n, center);
    cylinder(height/2, r_fask, r_fask, $fn=fn_fask*32, center);
  }
}

//базовая призма
module prizm_side(n, w, h, r, center = true)
{
  rotate([0,-90,180])
  {
    prizm_add_dfask(n, w, h, r,16, center);
  }
}
//призма - труба
module prizm_box(n, w, h, r, t, center = true)
{
  r2 = (r-t < 0) ? 0.1 :  r-t;
  rotate([0,-90,180]) difference()
  {
    prizm_add_dfask(n, w, h, r,16, center);
    translate([0,0,-0.5])prizm_add_dfask(n, w+3, h, r2,16, center);
  }
}








h=230;
r=10;
t= 5; // толщина корпуса
w=127;
z = h/(sqrt(3)*2) + r;
h2=40;
ts = 8; // толщина боковой стенки
ts2 = 5;


module stylus(h, r, fn_fask)
{
  difference()
  {
      union()
      {
        translate([0,0,h-r]) sphere(r,$fn=fn_fask*1);
        cylinder(h-r,r,r,$fn=fn_fask);
      }
      translate([-r,0,0]) cube([2*r, r, h]);
  }
}

module half_box_fask(w,l,h,r_fask,fn_fask)
{
  fn = fn_fask*4;
  translate([w/2,l/2,0]) hull()
  {
    translate([-w/2+r_fask,-l/2+r_fask,0]) stylus(h, r_fask, fn);
    translate([-w/2+r_fask,l/2,0]) stylus(h, r_fask, fn);
    translate([w/2-r_fask,-l/2+r_fask,0]) stylus(h, r_fask, fn);
    translate([w/2-r_fask,l/2,0]) stylus(h, r_fask, fn);
  }
}

module case_rk_top()
{
    difference() {
          
     half_box_fask(240,71,4,2,10);//cube([236,61,2],false);
     translate([10,10,-0.5])cube([96,55,2],false);
     translate([116,10,-0.5])cube([110,55,2],false);
     for (i=[140:6:200])
     translate([i-120,12,-0.5])rotate([00,00,70])cube([40,3,8],false);
    }


    translate([5.5,4.5,-6])   cube([5,66,6],false);
    translate([229.5,4.5,-6]) cube([5,66,6],false);
    translate([70,4.5,-6]) cube([100,4.5,6],false);
    //translate([10,0,-5]) cube([216,5,5],false);
    //translate([106,5,-5]) cube([10,45,5],false);
}

module stoyka_klav(x,y)
{
    translate([x,y,-5])
 difference() {
 cylinder($fn = 30, h = 6, r1 = 3.5, r2 = 3.5, center = false);
 cylinder($fn = 30, h = 6.5, r1 = 1.2, r2 = 1.2, center = false);   
    
}
}

module keyboard()
{
    difference() {
          
     half_box_fask(240,135,4,2,9);// cube([240,110,7],false);
     translate([2,20,0])
        {
             translate([172,41,-1.5]) cube([14,10,8],false); //пробел
        translate([64,-0.5,-1.5]) cube([60,13,8],false); //пробел
        translate([190,-0.5,-1.5]) cube([39,13,8],false);//стрелки влево вниз вправо
        translate([11,15,-1.5]) cube([166,13,8],false);  // нижний ряд
        translate([203,15,-1.5]) cube([13,13,8],false); //кнопка вверх
        translate([6,30,-1.5]) cube([180,13,8],false); //второй ряд снизу
        translate([13,45,-1.5])cube([154,13,8],false); // третий ряд снизу
        translate([172,45,-1.5])cube([14,13,8],false); //вк
        translate([190,45,-1.5])cube([39,13,8],false); //пс таб
        translate([6,60,-1.5])cube([170,13,8],false); // 4 ряд
        translate([190,60,-1.5])cube([39,13,8],false);
        translate([6.5,77.5,-1.5])cube([13,13,8],false); // сброс
        translate([33,78,-1.5])cube([56,13,8],false);
            
             
            
        }
            

    }
             stoyka_klav(30,26);
             stoyka_klav(62,26);
             stoyka_klav(131,26);
             stoyka_klav(182,26);
            
             stoyka_klav(30,98);
             stoyka_klav(105,98);
             stoyka_klav(182,95);
             stoyka_klav(225,42);
     translate([10.5,5.5,-5])rotate([0,0,90])cube([10,5,5],false);
     translate([10.5,120,-5])rotate([0,0,90])cube([15,5,5],false);
     translate([235,5.5,-5])rotate([0,0,90])cube([10,5,5],false);
     translate([235,120,-5])rotate([0,0,90])cube([15,5,5],false);
}





module stoyka(x,y)
{
    translate([x,y,-73])
 difference() {
 cylinder($fn = 30, h = 7, r1 = 3.5, r2 = 3.5, center = false);
 cylinder($fn = 30, h = 7.5, r1 = 1.2, r2 = 1.2, center = false);   
    
}
}



zw=240;
 module main_case()
intersection()
{
  //translate([0,50,h2/2])cube([169,h,h2],true); // уберем треугольник оставим санки # - подсветка  
      translate([0,0,h2/2])
  {
    hull()
    {  
      translate([0,-h/2+65,0]) cube([zw,71,h2],true); // уберем треугольник оставим санки # - подсветка   
     translate([0,h/2+20,-10])cube([zw,5,h2-20],true); //     
    }
  }
  translate([-00,0,z]) //rotate([0,0,0]) 
  union()
  {  
      difference() { 
       prizm_box(3, 240, h, r, t);
      
         
      /*    translate([-74,130,-65]) cube([159,6,5],false);   // фаска под клаву спереди 
       translate([-68,-87,-87.5]) cube([140,110,6],false); //дыра внизу 1
       translate([-68,37,-87.5])  cube([140,100,6],false);  //дыра внизу 2
       translate([-70,-87,-87.5]) cube([142,114,2.5],false); //фаска под дырку 1
       translate([-70,34,-87.5])  cube([142,104,2.5],false); //фаска под дырку 2
       //translate([-70,-80,-87.5]) cube([142,4,2.5],false); // фаска 
        translate([70,-83,-87.5]) cube([5,110,2.5],false); //фаска под дырку 1
          translate([70,34,-87.5]) cube([5,104,2.5],false); //фаска под дырку 1**/
      }
      difference() {
      translate([-120,0,0])prizm_side(3, ts2, h, r, 20); // боковая стенка
           // боковая стенка
     // translate([-64,-100,-52]) rotate([0,0,90]) cube([237,4,5],false);
     // translate([-63,-92,-87.5]) rotate([0,0,90])  cube([230,4,2.5],false);
     // translate([-64,18,-51.5])   rotate([0,6.8,90])  cube([126.7,4,5],false);//фаска на клаву на боковой стенке  
      }
      translate([115,0,0])prizm_side(3, ts2, h, r, 20); 
      
      // #stoyka(-94,-84);
      stoyka(-94,-76);
      stoyka(-22,-76);
      stoyka(106,-76);
      stoyka(-106,64);// -115х-81 правый левый угол -110х-81 правый верхний край платы
      stoyka(106,64);
      stoyka(-63,-4);
       stoyka(-12,65);
       stoyka(88,-7);
      stoyka(13,-7);
      difference() {
       translate([-120,-86,-86]) cube([240,5,50],false);// задняя стенка
       //-115 начало правой стенки
       translate([-100,-80,-53.5]) rotate([90,180,0])cube([10,10,6],false);// отверстие под питание
       translate([-28,-80,-51.5]) rotate([90,180,0])cube([52,12,6],false);// порт сдшки
       translate([43,-80,-51.5]) rotate([90,180,0])cube([52,12,6],false);// порт системный   
       translate([98,-80,-51.5]) rotate([90,180,0])cube([30,12,6],false);// порт системный  
       translate([-95,-80,-60]) rotate([90,0,0])cube([9,14,6.5],false);// выключатель 
      // translate([-70,-83,-52]) rotate([0,0,0]) cube([155,6,5],false); // фаска под крышку
      // translate([-70,-83,-87.5]) rotate([0,0,0]) cube([145,4,2.5],false); // фаска под крышку снизу
      // translate([-10,-78,-71]) rotate([90,0,00]) cube([56,12,6.5],false);
  //translate([-15,-85,-66]) rotate([90,0,00])#cylinder($fn = 0, h = 15, r1 = 1, r2 = 1, center = false);
  //translate([48,-85,-66]) rotate([90,0,00])#cylinder($fn = 0, h = 15, r1 = 1, r2 = 1, center = false);
       //
       //translate([-45,-78.5,-66]) rotate([90,180,0]) cylinder($fn = 0, h = 7, r1 = 8, r2 = 7.8, center = false); //питание  
      // translate([169/2,-78,-63]) rotate([90,180,0]) cube([9,14,3],false);// вставка для скрепления
      }
  }
  // translate([-0.5,5,34]) cube([237,6.5,6],false);
 }
 
module probel()
{
   
 difference() {
  cube([58,12,5],false);
  translate([1,1,-0.50])cube([56,10,4],false);  
}
}
 
 module enter()
{
   
 difference() {
  cube([27,12,5],false);
  translate([1,1,-0.50])cube([25,10,4],false);  
}
}
 

  translate([-120,0,0]) main_case();
  translate([-240,-85,40])case_rk_top();
  translate([-0,119.5,22]) rotate([7.5,0,180])keyboard();





//enter();