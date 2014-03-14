   SUBROUTINE BldGaussPointData(hhx,hpx,Nuuu,Nrrr,uu0,E10,node_elem,dof_node,&
                                &uuu,uup,E1,RR0,kapa,Stif,cet)

   REAL(ReKi),INTENT(IN):: hhx(:),hpx(:),Nuuu(:),Nrrr(:),uu0(:),E10(:)
   REAL(ReKi),INTENT(OUT):: uuu(:),uup(:),E1(:),RR0(:,:),kapa(:),cet
   REAL(ReKi),INTENT(INOUT):: Stif(:,:)
   INTEGER(IntKi),INTENT(IN):: node_elem,dof_node

   REAL(ReKi):: rrr(3),rrp(3),hhi,hpi,cc(3)
   REAL(ReKi):: rotu_temp(3),rot_temp(3),rot0_temp(3),Wrk(3,3),tempR6(6,6)
   INTEGER(IntKi):: inode,temp_id,temp_id2,i,j


   uuu = 0.0D0
   uup = 0.0D0
   rrr = 0.0D0
   rrp = 0.0D0
   DO inode=1,node_elem
       hhi = hhx(inode)
       hpi = hpx(inode)
       temp_id = (inode-1)*dof_node
       temp_id2 = (inode-1)*dof_node/2
       DO i=1,3
           uuu(i) = uuu(i) + hhi*Nuuu(temp_id+i)
           uup(i) = uup(i) + hpi*Nuuu(temp_id+i)
           rrr(i) = rrr(i) + hhi*Nrrr(temp_id2+i)
           rrp(i) = rrp(i) + hpi*Nrrr(temp_id2+i)
       ENDDO
   ENDDO

   E1 = 0.0D0
   rotu_temp = 0.0D0
   DO i=1,3
       E1(i) = E10(i) + uup(i)
       rotu_temp(i) = Nuuu(i+3)
   ENDDO
   rot_temp = 0.0D0
   rot0_temp = 0.0D0
   CALL CrvCompose(rot_temp,rotu_temp,rrr,0)
   DO i=1,3
       uuu(i+3) = rot_temp(i)
       rot0_temp(i) = uu0(i+3)
   ENDDO

   cc = 0.0D0
   RR0 = 0.0D0
   CALL CrvCompose(cc,rot_temp,rot0_temp,0)
   CALL CrvMatrixR(cc,RR0)

   tempR6 = 0.0D0
   DO i=1,3
       DO j=1,3
           tempR6(i,j) = RR0(i,j)
           tempR6(i+3,j+3) = RR0(i,j)
       ENDDO
   ENDDO

   cet = 0.0D0
   cet = Stif(5,5) + Stif(6,6)
   Stif = MATMUL(tempR6,MATMUL(Stif,TRANSPOSE(tempR6)))

   Wrk = 0.0D0
   kapa = 0.0D0
   CALL CrvMatrixH(rrr,Wrk)
   cc = MATMUL(Wrk,rrp)
   CALL CrvMatrixR(rotu_temp,Wrk)
   kapa = MATMUL(Wrk,cc)

   END SUBROUTINE BldGaussPointData