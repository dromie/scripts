#!/usr/bin/env python3
import sys
from mpmath import *

mp.dps = 1000
A=mpf(1)
B=mpf(-1)
half=mpf(0.5)


def calculate_50percent(no):
    single=(mpf(no)-mpf(1))/mpf(no)
    C=-log(half*half)/log(single)
    X1=(A+sqrt(A-4*A*C))/mpf(2)*A
    return ceil(X1)

def convergence(start, r):
    j=mpf(start)
    prev=1
    prevfact=0
    prevdiff=mpf(inf)
    for i in range(r):
        x=calculate_50percent(j)
        newfact=(x/prev)
        newdiff=(prevfact-newfact)
        if (abs(prevdiff)<abs(newdiff)):
            print(j)
            print(newfact)
            break
        prev=x
        prevfact=newfact
        prevdiff=newdiff
        j=j*mpf(10)

def snowkg():
    increment_constant=mpf("3.162277660168379331998893544432718533719555139325184943833950727040670470876242801043955700219983226144399032118744592948376849153931215846654673005152622908654285620908662096226813270416745950715691645227924050581797820726177719950402355567544403153508992351970778377644819070172433186957141518692869495846518549915856902272576354383919004894394662688288685261827791436320470539623220819609184255395884336737808479064312962085897343797544876485111082315020655860811722498785870126545513511101221126142269291613423205460027679112760359551008393250472831398977401781227282809927580113786278144083467280677818703987381383338529799173540235881689744976171779590624608497429751956677013940107054922513525821813839889027236215100003649410606134844004016159370735036387690383076836892273812547347209032970537366075269328130270316999759833313891495724904351382925842216908858029263209762834590554127433810668772675336206867382796264695076221593384947270806672355596590852344524575799265854547071503822073958")
    p30=calculate_50percent(power(mpf(10),30))
    #print(p30)
    #print(increment_constant)
    result = p30*power(increment_constant,128)
    mp.pretty=True
    print(result)
    mg=result/3
    kg=ceil(mg/mpf(1000000))
    print(f"{kg} kg")

def examples():
    print(f"Original birthday paradox: {calculate_50percent(365)}")
    print(f"intra-decade birthday paradox: {calculate_50percent(3650)}")
    print(f"intra-century birthday paradox: {calculate_50percent(36500)}")
    print(f"Snowflake birthday paradox: {calculate_50percent(power(mpf(10),158))}")
    print(f"Git sha1 paradox: {calculate_50percent(power(mpf(2),160))}")
    print(f"Git sha256 paradox: {calculate_50percent(power(mpf(2),256))}")


examples()
#convergence(10000000000000000001, 10000)
