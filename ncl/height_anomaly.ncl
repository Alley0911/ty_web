load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
;************************************************
begin
value = new(62,integer)
value = 5
value(22) = 9
args = asciiread("/home/alley/work/tyanalyse/project/ncl/params.txt", -1, "string")
start_year = stringtoint(args(0))
start_month = stringtoint(args(1))
end_year = stringtoint(args(2))
end_month = stringtoint(args(3))
north = stringtoint(args(4))
south = stringtoint(args(5))
west = stringtoint(args(6))
east = stringtoint(args(7))
data = (args(8))
var = (args(9))
leftstring = (args(10))
level = stringtoint(args(11))
filepath = "/home/alley/data/" + data + "/Height/"
pic_name = "/home/alley/work/tyanalyse/project/local_pic/result"

number = (end_year - start_year + 1) * (end_month - start_month +1)
files_cur = new(number, string)
n = 0
do y = start_year, end_year
    do m = start_month, end_month
        if (m .le. 9) then
            files_cur(n) = filepath + "height_" + y + "0" + m + ".grb"
        else
            files_cur(n) = filepath + "height_" + y + m + ".grb"
        end if
        n = n + 1
    end do
end do
print(files_cur)

; 根据时间获取所需要的气候态的文件
number = 30 * (end_month - start_month +1)
files_cli = new(number, string)
n = 0
do y = 1981, 2010
    do m = start_month, end_month
        if (m .le. 9) then
            files_cli(n) = filepath + "height_" + y + "0" + m + ".grb"
        else
            files_cli(n) = filepath + "height_" + y + m + ".grb"
        end if
        n = n + 1
    end do
end do
print(files_cli)
; 获取目标场的平均
f_cur    = addfiles (files_cur, "r")
ListSetType(f_cur, "join")
height_cur = f_cur[:]->Z_GDS0_ISBL_S123
height_cur = height_cur / 98
; printVarSummary(height)

if dimsizes(files_cur) .eq. 1 then
    ; print(dimsizes(files))
    height_avg_cur = height_cur
else
    height_avg_cur = dim_avg_n_Wrap(height_cur, 0)
end if

; 获取气候场的平均
f_cli    = addfiles (files_cli, "r")
ListSetType(f_cli, "join")
height_cli = f_cli[:]->Z_GDS0_ISBL_S123
height_cli = height_cli / 98
; printVarSummary(height)

if dimsizes(files_cli) .eq. 1 then
    ; print(dimsizes(files))
    height_avg_cli = height_cli
else
    height_avg_cli = dim_avg_n_Wrap(height_cli, 0)
end if

; 求异常场
height_ano = height_avg_cli
height_ano = height_avg_cur - height_avg_cli
height_ano = height_ano 
height_ano@long_name = ""
height_ano@units = ""
height_avg_cur@long_name = ""
height_avg_cur@units = ""


wks = gsn_open_wks("png", pic_name)                  ; send graphics to PNG file
res = True
res@gsnDraw           = False    ; Set to False so we can add 
res@gsnFrame          = False    ; shapefile outlines.
res@tmXTOn = False
res@tmYROn = False
res@cnLevelSelectionMode="ExplicitLevels"
res@cnLevels = ispan(500, 640, 4)
res@cnMonoLineThickness = False
res@cnLineThicknesses = value
res@cnLineThicknessF=5
res@cnInfoLabelOn=False
res@cnLineColor="black"
res@cnLineLabelInterval=1
res@tiMainString = leftstring
; res@tiMainFontHeightF = 0.018
res@tiMainOffsetYF = -0.02
res@cnLineLabelFontHeightF=0.014
plot1 = gsn_csm_contour(wks, height_avg_cur, res)         ; create a default plot

cnres                             = True
cnres@mpShapeMode = "FreeAspect"
cnres@vpWidthF = 0.8
cnres@vpHeightF = 0.6
cnres@vpXF = 0.1
cnres@vpYF = 0.8
cnres@mpMaxLatF = north
cnres@mpMinLatF = south
cnres@mpMinLonF = west
cnres@mpMaxLonF = east
cnres@gsnMaximize                 = True
cnres@gsnDraw                     = False
cnres@gsnFrame                    = False
cnres@gsnRightString          = ""
cnres@gsnLeftString           = ""  
cnres@gsnStringFontHeightF=15
cnres@cnLinesOn                   = False
cnres@cnLineLabelsOn=False
cnres@cnFillOn                    = True
cnres@cnFillPalette               = "BlueDarkRed18"
cnres@mpFillOn                    = False
cnres@mpGeophysicalLineColor      = "Grey18"
cnres@mpGeophysicalLineThicknessF = 1.5
cnres@tmXTOn = False
cnres@tmYROn = False
cnres@cnLevelSelectionMode="ExplicitLevels"
cnres@cnLevels=ispan(-8, 8, 1)
; cnres@tmYLMode="Explicit"
; cnres@tmYLDataBottomF=-40
; cnres@tmYLDataTopF=60
cnres@lbLabelBarOn        =  True
cnres@gsnAddCyclic                = False
; cnres@tmXBFontHeight=0.05

plot_ano = gsn_csm_contour_map(wks,height_ano,cnres)   
overlay(plot_ano,plot1)   
draw(plot_ano)
frame(wks)
end
